require 'json'

module Calabash
  module Android
    # A representation of a Calabash Android device.
    class Device < ::Calabash::Device
      attr_reader :adb

      def initialize(identifier, server)
        super
        @adb = ADB.new(identifier)
      end

      def self.default_serial
        serials = list_serials

        if Environment::DEVICE_IDENTIFIER
          index = serials.index(Environment::DEVICE_IDENTIFIER)

          if index
            serials[index]
          else
            raise "A device with the serial '#{Environment::DEVICE_IDENTIFIER}' is not visible on adb"
          end
        else
          if serials.length == 0
            raise 'No devices visible on adb. Ensure a device is visible in `adb devices`'
          end

          if serials.length > 1
            raise 'More than one device connected. Use CAL_DEVICE_ID to select serial'
          end

          serials.first
        end
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

      def installed_apps
        adb.shell('pm list packages -f').lines.map do |line|
          # line will be package:<path>=<package>
          # e.g. "package:/system/app/GoogleEars.apk=com.google.android.ears"
          info = line.sub("package:", "")

          app_path, app_id = info.split('=').map(&:chomp)

          {package: app_id, path: app_path}
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

      def port_forward(host_port)
        adb_forward_cmd = ['forward', "tcp:#{host_port}", "tcp:#{server.test_server_port}"]
        ADB.command(*adb_forward_cmd)
      end

      def make_map_parameters(query, map_method_name, *method_args)
        converted_args = []

        method_args.each do |arg|
          if arg.is_a?(Hash)
            if arg.keys.length > 1
              raise "Cannot map '#{arg}'. More than one key (method name) is not allowed."
            end

            if arg.keys.length == 0
              raise "Cannot map '#{arg}'. No key (method name) is given."
            end

            method_name = arg.keys.first.to_s
            value = arg.values.first

            if value.is_a?(Array)
              arguments = value
            else
              arguments = [value]
            end

            converted =
                {
                    method_name: method_name,
                    arguments: arguments
                }

            converted_args << converted
          elsif arg.is_a?(Symbol)
            method_name = arg.to_s
            converted_args << method_name
          else
            raise "Invalid value for map: '#{arg}' (#{arg.class})"
          end
        end

        {
          query: query,
          operation: {
                  method_name: map_method_name,
                  arguments: converted_args
          }
        }
      end

      # @!visibility private
      def map_route(query, method_name, *method_args)
        parameters = make_map_parameters(query, method_name, *method_args)

        request = HTTP::Request.new('map', params_for_request(parameters))

        result = JSON.parse(http_client.get(request).body)

        if result['outcome'] != 'SUCCESS'
          raise "mapping \"#{query}\" with \"#{method_name}\" failed because: #{result['reason']}\n#{result['details']}"
        end

        result['results']
      end

      def perform_action(action, *arguments)
        @logger.log "Action: #{action} - Arguments: #{arguments.join(', ')}"

        parameters = {command: action, arguments: arguments}
        request = HTTP::Request.new('/', params_for_request(parameters))

        result = JSON.parse(http_client.get(request).body)

        unless result['success']
          message = result['message'] || result['bonusInformation']

          if message.is_a?(Array)
            message = message.join("\n")
          end

          if message.nil?
            raise "Could not perform action '#{action}'"
          else
            raise message
          end
        end

        result
      end

      def enter_text(text)
        perform_action('keyboard_enter_text', text)
      end

      def md5_checksum(file_path)
        result = adb.shell("#{md5_binary} '#{file_path}'")
        captures = result.match(/(\w+)/).captures

        if captures.length != 1
          raise "Invalid MD5 result '#{result}' using #{md5_binary}"
        end

        captures[0]
      end

      # @!visibility private
      def backdoor(method, *arguments)
        parameters = {method_name: method, arguments: arguments}
        json = parameters.to_json
        request = HTTP::Request.new('/backdoor', json: json)

        body = http_client.get(request).body
        result = JSON.parse(body)

        if result['outcome'] != 'SUCCESS'
          details = if result['detail'].nil? || result['detail'].empty?
                      ''
                    else
                      "\n#{result['detail']}"
                    end

          raise "backdoor #{parameters} failed because: #{result['result']}#{details}"
        end

        result['result']
      end

      def set_location(location)
        perform_action('set_gps_coordinates',
                       location[:latitude], location[:longitude])
      end

      private

      def _start_app(application, options={})
        env_options = {}

        options.fetch(:extras, {}).each do |k, v|
          env_options[k] = v
        end

        env_options[:test_server_port] = server.test_server_port

        env_options[:class] = options.fetch(:class, 'sh.calaba.instrumentationbackend.InstrumentationBackend')
        env_options[:target_package] = options.fetch(:target_package, application.identifier)

        if options[:activity]
          env_options[:main_activity] = options[:activity]
        end

        if application.test_server.nil?
          raise 'Invalid application. No test-server set.'
        end

        unless app_installed?(env_options[:target_package])
          raise "The application '#{env_options[:target_package]}' is not installed"
        end

        unless app_installed?(application.test_server.identifier)
          raise "The test-server '#{application.test_server.identifier}' is not installed"
        end

        ensure_screen_on

        # Forward the port to the test-server
        port_forward(server.endpoint.port)

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

        # Return true to avoid cluttering the console
        true
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

        # Return true to avoid cluttering the console
        true
      end

      # @!visibility private
      def ensure_screen_on
        unless screen_on?
          # Tap the 'lock' button
          Logger.info "Screen is off, turning screen on."
          adb.shell('input keyevent 26')
        end

        time_start = Time.now

        while Time.now - time_start < 5
          return true if screen_on?
        end

        raise 'Could not turn screen on'
      end

      # @!visibility private
      def screen_on?
        # Lollipop removed this output
        if info[:sdk_version] < 20
          results = adb.shell('dumpsys input_method')
          output = results.lines.grep(/mScreenOn=(\w+)/)

          if output.empty?
            raise "Could not find 'mScreenOn'"
          end

          parsed_result = output.first.match(/mScreenOn=(\w+)/)
          parsed_result.captures.first == 'true'
        else
          results = adb.shell('dumpsys power')
          output = results.lines.grep(/mWakefulness=(\w+)/)

          if output.empty?
            raise "Could not find 'mWakefulness'"
          end

          parsed_result = output.first.match(/mWakefulness=(\w+)/)
          parsed_result.captures.first == 'Awake'
        end
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

        # Return true to avoid cluttering the console
        true
      end

      # @!visibility private
      def _install_app(application)
        @logger.log "About to install #{application.path}"

        if installed_packages.include?(application.identifier)
          @logger.log 'Application is already installed. Uninstalling application.'
          _uninstall_app(application)
        end

        adb_install_app(application)

        if application.is_a?(Android::Application)
          if application.test_server
            @logger.log 'Installing the test-server as well'
            install_app(application.test_server)
          end
        end

        # Return true to avoid cluttering the console
        true
      end

      # @!visibility private
      def _ensure_app_installed(application)
        @logger.log "Ensuring #{application.path} is installed"

        if installed_packages.include?(application.identifier)
          @logger.log 'Application is already installed. Ensuring right checksum'

          installed_app = installed_apps.find{|app| app[:package] == application.identifier}
          installed_app_md5_checksum = md5_checksum(installed_app[:path])

          if application.md5_checksum != installed_app_md5_checksum
            @logger.log("The md5 checksum has changed (#{application.md5_checksum} != #{installed_app_md5_checksum}.", :info)
            _install_app(application)
          end
        else
          adb_install_app(application)
        end

        if application.is_a?(Android::Application)
          if application.test_server
            @logger.log 'Ensuring the test-server is installed as well'
            ensure_app_installed(application.test_server)
          end
        end

        # Return true to avoid cluttering the console
        true
      end

      # @!visibility private
      def _uninstall_app(application)
        if installed_packages.include?(application.identifier)
          adb_uninstall_app(application.identifier)
        end

        if application.is_a?(Android::Application)
          if application.test_server
            @logger.log 'Uninstalling the test-server as well'
            uninstall_app(application.test_server)
          end
        end

        # Return true to avoid cluttering the console
        true
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
      def _pan(query, from, to, options={})
        from_x = from[:x]
        from_y = from[:y]
        from = {x: from_x, y: from_y}
        to_x = to[:x]
        to_y = to[:y]
        to = {x: to_x, y: to_y}
        duration = options[:duration]

        gesture = Gestures::Gesture.generate_swipe(from, to, time: duration)

        execute_gesture(Gestures::Gesture.with_parameters(gesture,
                                                          query_string: query.to_s,
                                                          timeout: options[:timeout]))
      end

      # @!visibility private
      def _flick(query, from, to, options={})
        from_x = from[:x]
        from_y = from[:y]
        from = {x: from_x, y: from_y}
        to_x = to[:x]
        to_y = to[:y]
        to = {x: to_x, y: to_y}
        duration = options[:duration]

        gesture = Gestures::Gesture.generate_swipe(from, to, time: duration, flick: true)

        execute_gesture(Gestures::Gesture.with_parameters(gesture,
                                                          query_string: query.to_s,
                                                          timeout: options[:timeout]))
      end

      # @!visibility private
      def _pinch(direction, query, options={})
        gesture = Gestures::Gesture.pinch(direction)

        execute_gesture(Gestures::Gesture.with_parameters(gesture,
                                                          query_string: query.to_s,
                                                          timeout: options[:timeout]))
      end

      # @!visibility private
      def adb_uninstall_app(package)
        @logger.log "Uninstalling #{package}"
        result = adb.command('uninstall', package, timeout: 60).lines.last

        if result.downcase.chomp != 'success'
          raise "Could not uninstall app: #{result.chomp}"
        end

        if installed_packages.include?(package)
          raise 'App was not uninstalled'
        end
      end

      # @!visibility private
      def adb_install_app(application)
        @logger.log "Installing #{application.path}"
        result = adb.command('install' , '-r', application.path, timeout: 60).lines.last

        if result.downcase.chomp != 'success'
          raise "Could not install app: #{result.chomp}"
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

        result['results'].first
      end

      # @!visibility private
      def params_for_request(parameters)
        {json: parameters.to_json}
      end

      # @!visibility private
      def md5_binary
        if @md5_binary
          @md5_binary
        else
          if adb.shell('md5', no_exit_code_check: true).chomp == 'md5 file ...'
            @md5_binary = 'md5'
          else
            # The device does not have 'md5'
            calmd5 = Calabash::Android.binary_location('calmd5', info[:cpu_architecture], can_handle_pie_binaries?)
            adb.command('push', calmd5, '/data/local/tmp/calmd5')
            @md5_binary = '/data/local/tmp/calmd5'
          end
        end
      end

      # @!visibility private
      def can_handle_pie_binaries?
        # Newer Androids requires PIE enabled executables, older Androids break on them
        info[:sdk_version] >= 16
      end

      # @!visibility private
      def detect_abi
        abi = adb.shell('getprop ro.product.cpu.abi').chomp

        if abi == 'armeabi-v7a'
          # armeabi-v7a does not necessarily support NEON vector instructions,
          # our binaries for this arch requires that, so if CPU does not support
          # NEON fall back to regular armeabi
          cpuinfo = adb.shell('cat /proc/cpuinfo')

          if cpuinfo.match /Features.*neon.*/
            abi
          else
            'armeabi'
          end
        else
          abi
        end
      end

      # @!visibility private
      def info
        @info ||=
            {
                os_version: adb.shell('getprop ro.build.version.release').chomp,
                sdk_version: adb.shell('getprop ro.build.version.sdk').to_i,
                product_name: adb.shell('getprop ro.product.name').chomp,
                model: adb.shell('getprop ro.product.model').chomp,
                cpu_architecture: detect_abi,
                manufacturer: adb.shell('getprop ro.product.manufacturer').chomp
            }
      end
    end
  end
end
