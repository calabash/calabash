module Calabash
  module Android
    class Device < Calabash::Android::Operations::Device
      attr_reader :adb

      def initialize(identifier, server)
        super
        @adb = ADB.new(identifier)
      end

      def self.default_serial
        serials = list_serials

        if serials.length == 0
          raise 'No devices visible on adb. Ensure a device is visible in `adb devices`'
        end

        if serials.length > 1
          raise 'More than one device connected. Use $CAL_IDENTIFIER to select serial'
        end

        serials.first
      end

      def self.list_serials
        output = ADB.command('devices')
        lines = output.lines
        index = lines.index{|line| line.start_with?('List of devices attached')}

        if index.nil?
          raise "Could not parse adb output: '#{lines}'"
        end

        device_lines = lines[(index+1)..-1].select{|line| line.strip != ''}

        device_lines.collect do |line|
          line.match(/([^\s]+)/).captures.first
        end
      end

      def installed_packages
        adb.shell('pm list packages').lines.map do |line|
          line.sub('package:', '').chomp
        end
      end

      def test_server_responding?
        begin
          http_client.get(HTTP::Request.new('ping'), retries: 1).body == 'pong'
        rescue HTTP::Error => _
          false
        end
      end

      def test_server_ready?
        begin
          http_client.get(HTTP::Request.new('ready')).body == 'true'
        rescue HTTP::Error => _
          false
        end
      end

      # Do not modify
      def port_forward(host_port)
        if Managed.managed?
          Managed.port_forward(host_port, self)
        else
          _port_forward(host_port)
        end
      end

      private

      def _start_app(application, options={})
        env_options = options.dup

        env_options[:test_server_port] ||= server.test_server_port
        env_options[:class] ||= 'sh.calaba.instrumentationbackend.InstrumentationBackend'
        env_options[:target_package] ||= application.identifier
        env_options[:main_activity] ||= application.main_activity

        if application.test_server.nil?
          raise 'Invalid application. No test-server set.'
        end

        unless app_installed?(env_options[:target_package])
          raise "The application '#{env_options[:target_package]}' is not installed"
        end

        unless app_installed?(application.test_server.identifier)
          raise "The test-server '#{application.test_server.identifier}' is not installed"
        end

        cmd_arguments = ['am instrument']

        env_options.each_pair do |key, val|
          cmd_arguments << ["-e \"#{key.to_s}\" \"#{val.to_s}\""]
        end

        cmd_arguments << "#{application.test_server.identifier}/sh.calaba.instrumentationbackend.CalabashInstrumentationTestRunner"

        cmd = cmd_arguments.join(" ")

        @logger.log "Starting test server using: '#{cmd}'"

        begin
          adb.shell(cmd)
        rescue ADB::ADBCallError => e
          @logger.log('ERROR: Could not start the application. adb shell output: ', :error)
          @logger.log(e.stderr, :error)

          raise 'Failed to start the application'
        end

        begin
          Retriable.retriable(tries: 30, interval: 1, timeout: 30) do
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

        # Return nil to avoid cluttering the console
        nil
      end

      # @!visibility private
      def _stop_app
        Retriable.retriable(tries: 5, interval: 1) do
          begin
            http_client.get(HTTP::Request.new('kill'), retries: 1, interval: 0)
          rescue HTTP::Error => _
            # It's fine that we can't contact the test-server, as it might already have been shut down
            if test_server_responding?
              raise 'Could not kill the test-server'
            end
          end
        end

        # Return nil to avoid cluttering the console
        nil
      end

      # @!visibility private
      def app_installed?(identifier)
        installed_packages.include?(identifier)
      end

      # @!visibility private
      def _screenshot(path)
        cmd = "java -jar \"#{Screenshot::SCREENSHOT_JAR_PATH}\" #{identifier} \"#{File.expand_path(path)}\""

        @logger.log "Taking screenshot using '#{cmd}'"
        raise 'Could not take screenshot' unless system(cmd)

        @logger.log("Saved screenshot as #{File.expand_path(path)}", :info)
        path
      end

      # @!visibility private
      def _clear_app_data(application)
        adb_clear_app_data(application.identifier)
      end

      # @!visibility private
      def _install_app(application)
        @logger.log "About to install #{application.path}"

        if installed_packages.include?(application.identifier)
          @logger.log 'Application is already installed. Uninstalling application.'
          _uninstall_app(application.identifier)
        end

        adb_install_app(application)

        if application.is_a?(Android::Application)
          if application.test_server
            @logger.log 'Installing the test-server as well'
            install_app(application.test_server)
          end
        end
      end

      # @!visibility private
      def _ensure_app_installed(application)
        @logger.log "Ensuring #{application.path} is installed"

        # @todo: Ensure it is the same app (checksum).
        if installed_packages.include?(application.identifier)
          @logger.log 'Application is already installed. Will not install.'
        else
          adb_install_app(application)
        end

        if application.is_a?(Android::Application)
          if application.test_server
            @logger.log 'Ensuring the test-server is installed as well'
            ensure_app_installed(application.test_server)
          end
        end
      end

      # @!visibility private
      def _uninstall_app(application)
        adb_uninstall_app(application.identifier)
      end

      # @!visibility private
      def _port_forward(host_port)
        adb_forward_cmd = ['forward', "tcp:#{host_port}", "tcp:#{server.test_server_port}"]
        ADB.command(*adb_forward_cmd)
      end

      # @!visibility private
      def _tap(query, options={})
        x = options[:at][:x]
        y = options[:at][:y]
        offset = options[:offset]

        gesture_options =
          {
              x: x,
              y: y,
              offset: offset,
          }

        gesture = Gestures::Gesture.tap(gesture_options)

        execute_gesture(Gestures::Gesture.with_parameters(gesture,
                                                 query_string: query.to_s,
                                                 timeout: options[:timeout]))
      end

      # @!visibility private
      def _double_tap(query, options={})
        x = options[:at][:x]
        y = options[:at][:y]
        offset = options[:offset]

        gesture_options =
            {
                x: x,
                y: y,
                offset: offset,
            }

        gesture = Gestures::Gesture.double_tap(gesture_options)

        execute_gesture(Gestures::Gesture.with_parameters(gesture,
                                                          query_string: query.to_s,
                                                          timeout: options[:timeout]))
      end

      # @!visibility private
      def _long_press(query, options={})
        x = options[:at][:x]
        y = options[:at][:y]
        offset = options[:offset]
        duration = options[:duration]

        gesture_options =
          {
              x: x,
              y: y,
              offset: offset,
              time: duration
          }

        gesture = Gestures::Gesture.tap(gesture_options)

        execute_gesture(Gestures::Gesture.with_parameters(gesture,
                                                 query_string: query.to_s,
                                                 timeout: options[:timeout]))
      end

      # @!visibility private
      def adb_uninstall_app(package)
        @logger.log "Uninstalling #{package}"
        result = adb.command('uninstall', package).lines.last

        if result.downcase.chomp != 'success'
          raise "Could not uninstall app: #{result}"
        end

        if installed_packages.include?(package)
          raise 'App was not uninstalled'
        end
      end

      # @!visibility private
      def adb_install_app(application)
        @logger.log "Installing #{application.path}"
        result = adb.command('install' , '-r', application.path).lines.last

        if result.downcase.chomp != 'success'
          raise "Could not install app: #{result}"
        end

        unless installed_packages.include?(application.identifier)
          raise 'App was not installed'
        end
      end

      # @!visibility private
      def adb_clear_app_data(package)
        @logger.log "Clearing #{package}"

        unless installed_packages.include?(package)
          raise "Cannot clear app. '#{package}' is not installed"
        end

        result = adb.shell("pm clear #{package}").lines.last

        if result.downcase.chomp != 'success'
          raise "Could not clear app: #{result}"
        end
      end

      # @!visibility private
      def execute_gesture(multi_touch_gesture)
        request = HTTP::Request.new('gesture', json: multi_touch_gesture.to_json)

        body = http_client.get(request, timeout: multi_touch_gesture.timeout + 10).body
        result = JSON.parse(body)

        if result['outcome'] != 'SUCCESS'
          raise "Failed to perform gesture. #{result['reason']}"
        end
      end
    end
  end
end
