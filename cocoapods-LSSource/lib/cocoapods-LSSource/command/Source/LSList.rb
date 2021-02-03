require 'filesize'

module Pod
  class Command
    class LSList < LSSource
        self.summary = 'cocoapods-LSSource 展示已下载的源码和大小'

        self.command = 'list'

        self.arguments = [
            CLAide::Argument.new('POD_NAMES', true, true)
        ]

        def initialize(argv)
          super
          @pods = argv.arguments.empty? ? [] : argv.arguments!
        end

        def run
          pattern = @pods.empty? ? "#{COMMON_TMP_DIR}/**/Pods/*" : "#{COMMON_TMP_DIR}/**/Pods/*{#{@pods.join(',')}}*"
          total_size = 0
          Dir.glob(pattern) do |path|
            pod_name = File.basename(path)
            pod_version = path.match(/#{pod_name}\-(.*)@/)[1]
            size = `du -sk #{path}`.split.first.to_i
            total_size += size
            UI.puts "#{pod_name}-#{pod_version}: #{Filesize.from("#{size} KB").pretty}"
          end
          UI.puts "总大小为：#{Filesize.from("#{total_size} KB").pretty}"
        end
      end
    end
end
