if ENV["APP_PATH"]
  Calabash::Environment::APP_PATH = ENV["APP_PATH"]
end

if ENV["TEST_APP_PATH"]
  Calabash::Environment::TEST_SERVER_PATH = ENV["TEST_APP_PATH"]
end


module Calabash
  module Android
    class Device < Calabash::Device
      def screen_on?
        true
      end

      def installed_apps
        packages = installed_packages

        packages.map{|p| {package: p, path: ''}}
      end

      def md5_checksum(file_path)
        "samplechecksum"
      end

      def adb_install_app(application)
        @logger.log "Patch: Installing #{application.path}"

        begin
          result = adb.command("install #{application.path}", timeout: 60)
        rescue ADB::ADBCallError => e
          raise "Failed to install the application on device: '#{e.message}'"
        end

        if result.lines.last.downcase.chomp != 'success'
          raise "Could not install app '#{application.identifier}': #{result.chomp}"
        end

        unless installed_packages.include?(application.identifier)
          raise "App '#{application.identifier}' was not installed"
        end
      end

      def _start_app(application, options={})
        env_options = {}

        options.fetch(:extras, {}).each do |k, v|
          env_options[k] = v
        end

        env_options[:target_package] = application.identifier

        if options[:activity]
          env_options[:main_activity] = options[:activity]
        end

        env_options[:test_server_port] = server.test_server_port
        env_options[:class] = options.fetch(:class, 'sh.calaba.instrumentationbackend.InstrumentationBackend')

        if application.test_server.nil?
          raise 'Invalid application. No test-server set.'
        end

        unless app_installed?(application.identifier)
          raise "The application '#{application.identifier}' is not installed"
        end

        unless app_installed?(application.test_server.identifier)
          raise "The test-server '#{application.test_server.identifier}' is not installed"
        end

        installed_app = installed_apps.find{|app| app[:package] == application.identifier}
        installed_app_md5_checksum = md5_checksum(installed_app[:path])

        if application.md5_checksum != installed_app_md5_checksum
          raise "The specified app is not the same as the installed app (#{application.md5_checksum} != #{installed_app_md5_checksum})."
        end

        installed_test_server = installed_apps.find{|app| app[:package] == application.test_server.identifier}
        installed_test_server_md5_checksum = md5_checksum(installed_test_server[:path])

        if application.test_server.md5_checksum != installed_test_server_md5_checksum
          raise "The specified test-server is not the same as the installed test-server (#{application.test_server.md5_checksum} != #{installed_test_server_md5_checksum})."
        end

        # We have to forward the port ourselves, as an old test-server could be
        # running on the old port. If the retriable client was able to
        # determine if the port had been forwarded, we would not need this.
        port_forward(server.endpoint.port, server.test_server_port)

        # For now, the test-server cannot rebind an existing socket.
        # So we have to stop any running Calabash servers from the client
        # for now.
        if test_server_responding?
          @logger.log("A test-server is already running on port #{server.test_server_port}")
          @logger.log("Trying to stop it")

          begin
            _stop_app
          rescue => _
            raise 'Failed to stop old running test-server'
          end
        end

        extras = ''

        env_options.each_pair do |key, val|
          extras = "#{extras} -e #{key.to_s} #{val.to_s}"
        end

        begin
          instrument(application,
                     'sh.calaba.instrumentationbackend.CalabashInstrumentationTestRunner',
                     extras)
        rescue ADB::ADBCallError => e
          raise "Failed to start the application: '#{e.stderr.lines.first.chomp}'"
        end

        begin
          Retriable.retriable(tries: 30, interval: 1, timeout: 30, on: RetryError) do
            unless test_server_responding?
              raise RetryError
            end
          end
        rescue RetryError => _
          @logger.log('Could not contact test-server', :error)
          @logger.log('For information, see the adb logcat', :error)
          raise 'Could not contact test-server'
        end

        begin
          Retriable.retriable(tries: 10, interval: 1, timeout: 10) do
            unless test_server_ready?
              raise RetryError
            end
          end
        rescue RetryError => _
          @logger.log('Test-server was never ready', :error)
          @logger.log('For information, see the adb logcat', :error)
          raise 'Test-server was never ready'
        end

        # Return true to avoid cluttering the console
        true
      end
    end
  end
end