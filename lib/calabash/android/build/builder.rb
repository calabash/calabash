require 'zip'

module Calabash
  module Android
    module Build
      # @!visibility private
      class Builder
        def initialize(application_path, options={})
          @application_path = application_path

          if options[:logger]
            @logger = options[:logger] || Logger.new
          else
            @logger = Logger.new
            @logger.default_log_level = :info
          end
        end

        def build
          apk_fingerprint = fingerprint_from_apk
          @logger.log "#{@application_path} was signed with a certificate with fingerprint #{apk_fingerprint}", :debug

          keystores = JavaKeystore.get_keystores
          if keystores.empty?
            @logger.log "No default keystores found."
            @logger.log "Please create one or run calabash setup-keystore to configure calabash to use an existing keystore."

            raise BuildError.new('No keystores found')
          end
          keystore = keystores.find { |k| k.fingerprint == apk_fingerprint}

          unless keystore
            @logger.log "#{@application_path} is not signed with any of the available keystores."
            @logger.log "Tried the following keystores:"
            keystores.each do |k|
              @logger.log k.location
            end
            @logger.log ""
            @logger.log "You can resign the app with #{keystores.first.location} by running:
      calabash resign #{@application_path}"

            @logger.log ""
            @logger.log "Notice that resigning an app might break some functionality."
            @logger.log "Getting a copy of the certificate used when the app was build will in general be more reliable."

            raise BuildError.new("#{@application_path} is not signed with any of the available keystores")
          end

          application = Calabash::Application.from_path(@application_path)

          test_server_file_name = TestServer.new(@application_path).path
          FileUtils.mkdir_p File.dirname(test_server_file_name) unless File.exist? File.dirname(test_server_file_name)

          Dir.mktmpdir do |workspace_dir|
            Dir.chdir(workspace_dir) do
              FileUtils.cp(UNSIGNED_TEST_SERVER_APK, "TestServer.apk")
              FileUtils.cp(ANDROID_MANIFEST_PATH, "AndroidManifest.xml")

              contents = File.read('AndroidManifest.xml')
              contents.gsub!(/#targetPackage#/, application.identifier)
              contents.gsub!(/#testPackage#/, "#{application.identifier}.test")

              File.open('AndroidManifest.xml_tmp', 'w') {|file| file.write(contents)}
              FileUtils.mv('AndroidManifest.xml_tmp', 'AndroidManifest.xml')

              unless system %Q{"#{Environment.aapt_path}" package -M AndroidManifest.xml  -I "#{Environment.android_jar_path}" -F dummy.apk}
                raise "Could not create dummy.apk"
              end

              Zip::File.new("dummy.apk").extract("AndroidManifest.xml","customAndroidManifest.xml")
              Zip::File.open("TestServer.apk") do |zip_file|
                zip_file.add("AndroidManifest.xml", "customAndroidManifest.xml")
              end
            end
            keystore.sign_apk("#{workspace_dir}/TestServer.apk", test_server_file_name)
            begin

            rescue => e
              @logger.log e, :debug
              raise BuildError.new("Could not sign test server")
            end
          end
          @logger.log "Done signing the test server. Moved it to #{test_server_file_name}"
        end

        def fingerprint_from_apk
          application_path = File.expand_path(@application_path)

          Dir.mktmpdir do |tmp_dir|
            Dir.chdir(tmp_dir) do
              FileUtils.cp(application_path, "app.apk")
              FileUtils.mkdir("META-INF")
              Zip::File.foreach("app.apk") do |z|
                z.extract if /^META-INF\/\w+.(rsa|dsa)/i =~ z.name
              end
              signature_files = Dir["#{tmp_dir}/META-INF/*"]

              Logger.debug 'Signature files:'

              signature_files.each do |signature_file|
                Logger.debug signature_file
              end

              raise "No signature files found in META-INF. Cannot proceed." if signature_files.empty?
              raise "More than one signature file (DSA or RSA) found in META-INF. Cannot proceed." if signature_files.length > 1

              cmd = "#{Calabash::Android::Environment.keytool_path} -v -printcert -J\"-Dfile.encoding=utf-8\" -file \"#{signature_files.first}\""
              Logger.debug cmd
              fingerprints = `#{cmd}`
              md5_fingerprint = JavaKeystore.extract_md5_fingerprint(fingerprints)
              Logger.debug "MD5 fingerprint for signing cert (#{application_path}): #{md5_fingerprint}"
              md5_fingerprint
            end
          end
        end
      end
    end
  end
end
