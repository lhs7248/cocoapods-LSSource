module Pod
  class LSBinaryHelper

    SOURCE_SPECS_URL = 'git@github.com:lhs7248/repo.git'.freeze
    COMMON_TMP_DIR = '/Users/data/tmp/'.freeze

    def self.spec_in_source(source, name, version)
      begin
        spec = source.specification(name, version)
      rescue Pod::StandardError => error
        # 第一次找不到 podspec 的时候自动尝试一次 pod repo update
        if source.instance_variable_get(:@repo_udpated)
          raise error
        else
          UI.puts " 找不到 #{name}-#{version} spec 地址，即将尝试自动 update repo".red
          source.update(true)
          source.instance_variable_set(:@repo_udpated, true)
          retry
        end
      end
      spec
    end


    def self.check_tmp_dir_mode
      unless File.exist?(COMMON_TMP_DIR)
        # 有的人机器上不存在 COMMON_TMP_DIR，需要创建一下
        UI.puts "源码功能需要创建 #{COMMON_TMP_DIR} 并开启写权限，请输入 root 密码："
        system "sudo mkdir -p #{COMMON_TMP_DIR} && sudo chmod 777 #{COMMON_TMP_DIR}"
        return
      end
      stat = File.stat(COMMON_TMP_DIR)
      unless stat.writable?
        UI.puts "源码功能需要对 #{COMMON_TMP_DIR} 开启写权限，即将执行 sudo chmod 777 #{COMMON_TMP_DIR}:"
        system "sudo chmod 777 #{COMMON_TMP_DIR}"
      end
    end
  end
end

