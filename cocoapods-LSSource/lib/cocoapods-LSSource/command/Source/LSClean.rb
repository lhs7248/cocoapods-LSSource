module Pod
  class Command
    class LSClean < LSSource

      self.summary = "清理已下载的代码"
      self.command = 'clean'

      def run
        super

        Dir.glob("#{COMMON_TMP_DIR}/**/Pods") do |path|
          FileUtils.rm_rf(path)
          UI.message "成功删除 #{path}"
        end
        UI.puts '源码清空成功'.green

      end
    end
  end
end



