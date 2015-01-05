module Calabash
  module Android
    module Build
      class Resigner
        def initialize(application_path, options={})
          @application_path = application_path

          if options[:logger]
            @logger = options[:logger] || Logger.new
          else
            @logger = Logger.new
            @logger.default_log_level = :info
          end
        end

        def resign!
          Dir.mktmpdir do |tmp_dir|
            @logger.log 'Resigning apk', :debug
            unsigned_path = File.join(tmp_dir, 'unsigned.apk')
            unaligned_path = File.join(tmp_dir, 'unaligned.apk')
            FileUtils.cp(@application_path, unsigned_path)
            unsign(unsigned_path)
            sign(unsigned_path, unaligned_path)
            zipalign(unaligned_path, @application_path)
          end
        end

        def unsign(unsigned_path)
          files_to_remove = `"#{Calabash::Android::Environment.tools_dir}/aapt" list "#{unsigned_path}"`.lines.collect(&:strip).grep(/^META-INF\//)
          if files_to_remove.empty?
            @logger.log "App wasn't signed. Will not try to unsign it.", :debug
          else
            system("\"#{Calabash::Android::Environment.tools_dir}/aapt\" remove \"#{unsigned_path}\" #{files_to_remove.join(" ")}")
          end
        end

        def zipalign(unaligned_path, app_path)
          cmd = %Q("#{Calabash::Android::Environment.zipalign_path}" -f 4 "#{unaligned_path}" "#{app_path}")
          @logger.log "Zipaligning using: #{cmd}", :debug
          system(cmd)
        end

        def sign(app_path, dest_path)
          java_keystore = JavaKeystore.get_keystores.first

          if java_keystore.nil?
            raise 'No keystores found. You can specify the keystore location and credentials using calabash setup'
          end

          java_keystore.sign_apk(app_path, dest_path)
        end
      end
    end
  end
end