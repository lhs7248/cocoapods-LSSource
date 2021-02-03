require 'cocoapods-LSSource/command/LSBinaryHelper'
module Pod
  class Command
    class Add < LSSource
        self.summary = ' Source 在不删除二进制的情况下为某个组件添加源码调试能力，多个组件名称用空格分隔'

        self.command = 'add'

        self.arguments = [
            CLAide::Argument.new('POD_NAMES', true, true)
        ]

        def initialize(argv)
          super
          @source_manager = config.sources_manager.find_or_create_source_with_url(LSBinaryHelper::SOURCE_SPECS_URL)
          @pods = argv.arguments.empty? ? [] : argv.arguments!
          @pod_with_spec = config.podfile.dependencies.each_with_object({}) do |dep, result|
            next unless dep.to_root_dependency.requirement.exact?
            next unless @pods.include?(dep.root_name)

            name = dep.root_name
            version = dep.to_root_dependency.requirement.requirements.flatten.last.to_s
            result[name] = LSBinaryHelper.spec_in_source(@source_manager, name, version)
          end
        end

        def validate!
          super
          help! 'pod source add 需要指定 pod 名称' if @pods.empty?

          @pods.each do |pod_name|
            help! "组件 #{pod_name} 在当前 Podfile 中没有使用 `binary_pod` 声明依赖" unless @pod_with_spec[pod_name]
          end

          LSBinaryHelper.check_tmp_dir_mode
        end

        def run
          @pods.each do |pod_name|
            spec = @pod_with_spec[pod_name]

            next unless download_path = download_path(pod_name) # rubocop:disable Lint/AssignmentInCondition

            if File.exist?(download_path)
              UI.puts "#{pod_name} 的源码已存在于 #{download_path}，跳过源码下载".yellow
              next
            end

            FileUtils.mkdir_p(download_path)
            request = Downloader::Request.new(spec: spec, released: true)
            UI.puts "开始下载 #{pod_name} 源码..."
            Downloader.download(request, Pathname.new(download_path))
            UI.puts "#{pod_name} 源码下载成功!".green
          end

        end

        def download_path(pod_name)
          lib_dir_path = File.join(config.sandbox_root.to_s, pod_name)

          unless File.exist?(lib_dir_path)
            UI.puts "#{pod_name} 的二进制不存在于 Pods 目录中".yellow
            return nil
          end


          lib_path =   Dir.glob("#{lib_dir_path}/*.framework").first

          unless File.exist?(lib_path)
            UI.puts "#{pod_name} 的二进制不存在于 Pods 目录中".red
          end

          binaryPath = File.join(lib_path,pod_name)

          match_data = `dwarfdump --debug-info #{binaryPath} | head -1000 | grep AT_comp_dir | head -1`.match(/.*AT_comp_dir\s*\(\s*\"(.*)\".*/)
          if match_data.nil?
            UI.puts "#{pod_name} 的二进制中没有查找到对应的源码地址".yellow
            return nil
          end

          File.join(match_data[1], pod_name)
        end
      end
  end
end
