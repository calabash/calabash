require 'json'

module Calabash
  module Android
    # A representation of a Calabash Android device.
    # @!visibility private
    class Device < ::Calabash::Device
      attr_reader :adb

      def initialize(identifier, server)
        super
        @adb = ADB.new(identifier)

        http_client.on_error(Errno::ECONNREFUSED) do |server|
          port_forward(server.endpoint.port, server.test_server_port)
        end
      end

      # @!visibility private
      def change_server(new_server)
        super(new_server)
        port_forward(new_server.endpoint.port, new_server.test_server_port)
      end

      # @!visibility private
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

      # @!visibility private
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

      # @!visibility private
      def installed_packages
        adb.shell('pm list packages').lines.map do |line|
          line.sub('package:', '').chomp
        end
      end

      # @!visibility private
      def installed_apps
        adb.shell('pm list packages -f').lines.map do |line|
          # line will be package:<path>=<package>
          # e.g. "package:/system/app/GoogleEars.apk=com.google.android.ears"
          info = line.sub("package:", "")

          app_path, app_id = info.split('=').map(&:chomp)

          {package: app_id, path: app_path}
        end
      end

      # @!visibility private
      def test_server_responding?
        begin
          http_client.post(HTTP::Request.new('ping'), retries: 1).body == 'pong'
        rescue HTTP::Error => _
          false
        end
      end

      # @!visibility private
      def test_server_ready?
        begin
          http_client.post(HTTP::Request.new('ready')).body == 'true'
        rescue HTTP::Error => _
          false
        end
      end

      # @!visibility private
      def port_forward(host_port, test_server_port = nil)
        if test_server_port.nil?
          test_server_port = server.test_server_port
        end

        adb_forward_cmd = ['forward', "tcp:#{host_port}", "tcp:#{test_server_port}"]
        adb.command(*adb_forward_cmd)
      end

      # @!visibility private
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

        http_result = if method_name == :flash
                        http_client.post(request, timeout: 30)
                      else
                        http_client.post(request)
                      end

        result = JSON.parse(http_result.body)

        if result['outcome'] != 'SUCCESS'
          raise "mapping \"#{query}\" with \"#{method_name}\" failed because: #{result['reason']}\n#{result['details']}"
        end

        Calabash::QueryResult.create(result['results'], query)
      end

      # @!visibility private
      def perform_action(action, *arguments)
        @logger.log "Action: #{action} - Arguments: #{arguments.join(', ')}"

        parameters = {command: action, arguments: arguments}
        request = HTTP::Request.new('', params_for_request(parameters))

        result = JSON.parse(http_client.post(request).body)

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

      # @!visibility private
      def enter_text(text)
        perform_action('keyboard_enter_text', text)
      end

      # @!visibility private
      def md5_checksum_for_app_package(package)
        app = installed_apps.find{|app| app[:package] == package}

        unless app
          raise "Application with package '#{app}' not installed"
        end

        md5_checksum(app[:path])
      end

      # @!visibility private
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

        body = http_client.post(request).body
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


      # @!visibility private
      def keyboard_visible?
        input_method = adb.shell("dumpsys input_method")
        input_method.lines.each do |line|
          match = line.match(/mInputShown\s*=\s*(.*)/)

          if match && match.captures.length != 0
            shown = match.captures.first.chomp

            if shown == "true"
              return true
            elsif shown == "false"
              return false
            else
              raise "Could not detect keyboard visibility. '#{shown}'"
            end
          end
        end

        raise "Could not detect keyboard visibility. Could not find 'mInputShown'"
      end

      # @!visibility private
      def go_home
        adb.shell("input keyevent 3")
      end

      # @!visibility private
      def set_location(location)
        perform_action('set_gps_coordinates',
                       location[:latitude], location[:longitude])
      end

      # @!visibility private
      def resume_app(path_or_application)
        application = parse_path_or_app_parameters(path_or_application)

        if app_running?(application)
          main_activity = nil

          begin
            main_activity = application.main_activity
          rescue
            raise 'Could not detect a launchable activity. This is needed to resume the app'
          end

          resume_activity(application.identifier, main_activity)
        else
          raise "The app '#{application.identifier}' is not running"
        end

        true
      end

      # @!visibility private
      def resume_activity(package, activity)
        if package_running?(package)
          if info[:sdk_version] >= 11
            begin
              perform_action('resume_application', package)
            rescue EnsureInstrumentActionError => e
              raise "Failed to resume app: #{e.message}"
            end
          else
            adb.shell("am start -n '#{package}/#{activity}'")
          end
        else
          raise "The app '#{package}' is not running"
        end
      end

      # @!visibility private
      def app_running?(path_or_application)
        application = parse_path_or_app_parameters(path_or_application)

        package_running?(application.identifier)
      end

      # @!visibility private
      def current_focus
        # Example: mFocusedApp=AppWindowToken{42c52610 token=Token{42b5d048 ActivityRecord{42a7bcc8 u0 com.example/.MainActivity t3}}}
        result = adb.shell('dumpsys window windows')

        grep_words = ['mCurrentFocus', 'mFocusedApp']

        grep_words.each do |grep_word|
          result.lines.reverse.each do |line|
            match = line.match(/#{grep_word}=.*\{[\w]+\s*([\w\.\:\!]+\s*)*\/*([\w\.]+)*/)

            if match && match.captures.length == 2 && !match.captures.any?(&:nil?)
              captures = match.captures
              package = captures[0]
              activity_simple_name = captures[1]

              activity = if activity_simple_name.start_with?('.')
                           "#{package}#{activity_simple_name}"
                         else
                           activity_simple_name
                         end

              return {activity: activity, package: package}
            end
          end
        end

        raise "Unexpected output from `dumpsys window windows`"
      end

      # @!visibility private
      def evaluate_javascript_in(query, javascript)
        parameters =
            {
                query: Query.new(query),
                operation: {method_name: 'execute-javascript'},
                javascript: javascript
            }

        json = parameters.to_json
        request = HTTP::Request.new('/map', json: json)

        body = http_client.post(request).body
        result = JSON.parse(body)

        if result['outcome'] != 'SUCCESS'
          if result['results']
            parsed_result = result['results'].map {|r| "\"#{r}\","}.join("\n")

            raise "Could not evaluate javascript: \n#{parsed_result}"
          else
            raise "Could not evaluate javascript: \n#{result['detail']}"
          end
        end

        Calabash::QueryResult.create(result['results'], query)
      end

      private

      def package_running?(package)
        running_packages.include?(package)
      end

      def running_packages
        ps.lines.map(&:split).map(&:last)
      end

      def ps
        adb.shell('ps')
      end

      def calabash_server_failure_file_path(application)
        "/data/data/#{application.test_server.identifier}/files/calabash_failure.out"
      end

      def calabash_server_finished_file_path(application)
        "/data/data/#{application.test_server.identifier}/files/calabash_finished.out"
      end

      def adb_file_exists?(file)
        cmd = "ls #{file}"
        adb.shell(cmd, no_exit_code_check: true).chomp == file
      end

      def calabash_server_failure_exists?(application)
        adb_file_exists?(calabash_server_failure_file_path(application))
      end

      def calabash_server_finished_exists?(application)
        adb_file_exists?(calabash_server_finished_file_path(application))
      end

      def read_calabash_sever_failure(application)
        adb.shell("cat #{calabash_server_failure_file_path(application)}")
      end

      def read_calabash_sever_finished(application)
        adb.shell("cat #{calabash_server_finished_file_path(application)}")
      end

      def clear_calabash_server_report(application)
        if installed_packages.include?(application.test_server.identifier)
          adb.shell("am start -e method clear -n #{application.test_server.identifier}/sh.calaba.instrumentationbackend.StatusReporterActivity")
        end
      end

      def _start_app(application, options={})
        env_options = {}

        options.fetch(:extras, {}).each do |k, v|
          env_options[k] = v
        end

        env_options[:test_server_port] = server.test_server_port

        env_options[:class] = options.fetch(:class, 'sh.calaba.instrumentationbackend.InstrumentationBackend')

        if options[:activity]
          env_options[:main_activity] = options[:activity]
        else
          env_options[:main_activity] = 'null'
        end

        if application.test_server.nil?
          raise 'Invalid application. No test-server set.'
        end

        unless app_installed?(application.identifier)
          raise "The application '#{application.identifier}' is not installed"
        end

        unless app_installed?(application.test_server.identifier)
          raise "The test-server '#{application.test_server.identifier}' is not installed"
        end

        installed_app_md5_checksum = md5_checksum_for_app_package(application.identifier)

        if application.md5_checksum != installed_app_md5_checksum
          raise "The specified app is not the same as the installed app (#{application.md5_checksum} != #{installed_app_md5_checksum})."
        end

        installed_test_server_md5_checksum = md5_checksum_for_app_package(application.test_server.identifier)

        if application.test_server.md5_checksum != installed_test_server_md5_checksum
          raise "The specified test-server is not the same as the installed test-server (#{application.test_server.md5_checksum} != #{installed_test_server_md5_checksum})."
        end

        ensure_screen_on

        # Clear any old error reports
        clear_calabash_server_report(application)

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
              # Read any message the test-server might have
              if calabash_server_failure_exists?(application)
                failure_message = read_calabash_sever_failure(application)

                raise "Failed to start the application: #{parse_failure_message(failure_message)}"
              end

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

        start_application(options[:intent])

        # Return true to avoid cluttering the console
        true
      end

      # @!visibility private
      def start_application(intent)
        request = HTTP::Request.new('start-application', params_for_request(intent: intent))
        body = http_client.post(request).body

        result = JSON.parse(body)

        if result['outcome'] != 'SUCCESS'
          raise "Failed to start application. Reason: #{result['reason']}"
        end

        result['result']
      end

      # @!visibility private
      def _stop_app
        Retriable.retriable(tries: 5, interval: 1) do
          begin
            http_client.post(HTTP::Request.new('kill'), retries: 1, interval: 0)
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

      def parse_failure_message(message)
        case message
          when 'E_NO_LAUNCH_INTENT_FOR_PACKAGE'
            'The application does not have an default launchable activity. Specify :activity in #start_app'
          when 'E_COULD_NOT_DETECT_MAIN_ACTIVITY'
            'Could not detect the main activity of the application. Specify :activity in #start_app'
          when 'E_NO_INTERNET_PERMISSION'
            'The application does not have internet permission. Add the internet permission to your manifest'
          else
            message
        end
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
      def instrument(application, test_server_activity, extras = '')
        unless application.is_a?(Android::Application)
          raise ArgumentError, "Invalid application type '#{application.class}'"
        end

        if application.test_server.nil?
          raise ArgumentError, "No test server set for '#{application}'"
        end

        unless app_installed?(application.identifier)
          raise "The application #{application.identifier}' is not installed"
        end

        unless app_installed?(application.test_server.identifier)
          raise "The test-server '#{application.test_server.identifier}' is not installed"
        end

        cmd = "am instrument #{extras} #{application.test_server.identifier}/#{test_server_activity}"

        @logger.log "Starting '#{test_server_activity}' using: '#{cmd}'"

        adb.shell(cmd)
      end

      # @!visibility private
      class EnsureInstrumentActionError < RuntimeError; end

      # @!visibility private
      def ensure_instrument_action(application, test_server_activity, extras = '')
        clear_calabash_server_report(application)

        begin
          instrument(application, test_server_activity, extras)
        rescue ADB::ADBCallError => e
          raise EnsureInstrumentActionError, e
        end

        begin
          Timeout.timeout(10) do
            loop do
              if calabash_server_failure_exists?(application)
                failure_message = read_calabash_sever_failure(application)

                raise EnsureInstrumentActionError, parse_failure_message(failure_message)
              end

              if calabash_server_finished_exists?(application)
                output = read_calabash_sever_finished(application)

                if output == 'SUCCESSFUL'
                  break
                end
              end
            end
          end
        rescue Timeout::Error => _
          raise EnsureInstrumentActionError, 'Timed out waiting for status'
        end
      end

      # @!visibility private
      def ts_clear_app_data(application)
        begin
          ensure_instrument_action(application, 'sh.calaba.instrumentationbackend.ClearAppData2')
        rescue EnsureInstrumentActionError => e
          raise "Failed to clear app data: #{e.message}"
        end
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
        ts_clear_app_data(application)

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

          installed_app_md5_checksum = md5_checksum_for_app_package(application.identifier)

          if application.md5_checksum != installed_app_md5_checksum
            @logger.log("The md5 checksum has changed (#{application.md5_checksum} != #{installed_app_md5_checksum}).", :info)
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
                                                 query: query,
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
                                                          query: query,
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
                                                 query: query,
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
                                                          query: query,
                                                          timeout: options[:timeout]))
      end

      # @!visibility private
      def _pan_between(query_from, query_to, options={})
        gesture = Gestures::Gesture.generate_swipe({x: 50, y: 50}, {x: 50, y: 50}, time: options[:duration])
        gesture.gestures.first.touches[0].query = query_from
        gesture.gestures.first.touches[1].query = query_to

        result = execute_gesture(Gestures::Gesture.with_parameters(gesture,
                                                          query: query_to,
                                                          timeout: options[:timeout]))

        {
            :from => Calabash::QueryResult.create(result[0], query_from),
            :to => Calabash::QueryResult.create(result[1], query_to)
        }
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
                                                          query: query,
                                                          timeout: options[:timeout]))
      end

      # @!visibility private
      def _pinch(direction, query, options={})
        gesture = Gestures::Gesture.pinch(direction)

        execute_gesture(Gestures::Gesture.with_parameters(gesture,
                                                          query: query,
                                                          timeout: options[:timeout]))
      end

      # @!visibility private
      def adb_uninstall_app(package)
        @logger.log "Uninstalling #{package}"
        result = adb.command('uninstall', package, timeout: 60).lines.last

        if result.downcase.chomp != 'success'
          raise "Could not uninstall app '#{package}': #{result.chomp}"
        end

        if installed_packages.include?(package)
          raise "App '#{package}' was not uninstalled"
        end
      end

      # @!visibility private
      def adb_install_app(application)
        # Because of a bug in the latest version of ADB
        # https://github.com/android/platform_system_core/blob/0f91887868e51de67bdf9aedc97fbcb044dc1969/adb/commandline.cpp#L1466
        # ADB now uses rm -f ... to remove the temporary application on the
        # device, but not all devices (below a certain OS) supports this flag.
        # The user will be unable to install the app and instead receive:
        # RuntimeError: Could not install app 'com.xamarin.xtcandroidsample.test': rm failed for -f, No such file or directory
        # We have rewritten the way adb handles app installation. It's a 3-step
        # procedure:
        #  - Push the app binary to /data/local/tmp
        #  - Install the app binary using pm
        #  - Remove the temporary apk.
        @logger.log "Installing #{application.path}"

        tmp_path = "/data/local/tmp/#{File.basename(application.path)}"

        begin
          adb.command('push', application.path, tmp_path, timeout: 60)
        rescue ADB::ADBCallError => e
          raise "Failed to push the application to the device storage: '#{e.message}'"
        end

        begin
          result = nil

          begin
            result = adb.shell("pm install -r #{tmp_path}", timeout: 60)
          rescue ADB::ADBCallError => e
            raise "Failed to install the application on device: '#{e.message}'"
          end

          if result.lines.last.downcase.chomp != 'success'
            raise "Could not install app '#{application.identifier}': #{result.chomp}"
          end

          unless installed_packages.include?(application.identifier)
            raise "App '#{application.identifier}' was not installed"
          end
        rescue => e
          begin
            adb.shell("rm #{tmp_path}")
          rescue ADB::ADBCallError => _
          end

          raise e
        end

        begin
          adb.shell("rm #{tmp_path}")
        rescue ADB::ADBCallError => e
          raise "Failed to remove the tmp apk from device: #{e.message}"
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
          raise "Could not clear app '#{package}': #{result.chomp}"
        end
      end

      # @!visibility private
      def execute_gesture(multi_touch_gesture)
        request = HTTP::Request.new('gesture', params_for_request(multi_touch_gesture))

        body = http_client.post(request, timeout: multi_touch_gesture.timeout + 10).body
        result = JSON.parse(body)

        if result['outcome'] != 'SUCCESS'
          raise "Failed to perform gesture. #{result['reason']}"
        end

        result = result['results'].first

        results = []
        queries = multi_touch_gesture.queries

        result.each do |key, value|
          query = queries.find{|query| query.to_s == key}
          results << QueryResult.create([value], query)
        end

        if results.length == 1
          results.first
        else
          results
        end
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
          elsif adb.shell('md5sum _cal_no_such_file', no_exit_code_check: true).chomp.start_with?('md5sum:')
            @md5_binary = 'md5sum'
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

      def world_module
        Calabash::Android
      end
    end
  end
end
