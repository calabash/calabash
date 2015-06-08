module Calabash
  module Android
    class Device < Calabash::Android::Device
      attr_reader :adb

      def initialize(identifier, server)
        super
        @adb = ADB.new(identifier)
      end

      def map_route(query, method_name, *method_args)
        parameters =
              {
                    :query => query,
                    :operation =>
                          {
                                :method_name => method_name,
                                :arguments => method_args
                          }
              }
        request = Calabash::HTTP::Request.request('map', parameters)
        res = http_client.post(request).body

        res = JSON.parse(res)
        if res['outcome'] != 'SUCCESS'
          # Reason can be 'nil'
          # Can return 'detail' or 'details?'
          raise "map #{query}, #{method_name} failed because: #{res['reason'] || 'unknown'}\n#{res['details'] || res['detail']}"
        end

        res['results']
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
          _uninstall_app(application)
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
      end

      def _enter_text(text)
        perform_action('keyboard_enter_text', text)
      end

    end
  end
end

require 'json'

module Calabash
  module Android
    module Gestures
      class MultiTouchGesture
        attr_reader :gestures
        attr_accessor :timeout

        def initialize(gestures = [])
          unless gestures.is_a?(Array)
            gestures = [gestures]
          end

          @gestures = gestures
        end

        def +(gesture_collection)
          MultiTouchGesture.new(@gestures + gesture_collection.gestures)
        end

        def add_gesture
          gestures = @gestures
          MultiTouchGesture.new(gestures + gesture_collection.gestures)
        end

        def <<(gesture)
          @gestures << gesture
        end

        def add_touch(touch, index=0)
          gestures = @gestures
          gestures[index] << touch
          MultiTouchGesture.new(gestures)
        end

        def add_touch!(touch, index=0)
          @gestures = add_touch(touch, index).gestures
        end

        def merge(multi_touch_gesture)
          MultiTouchGesture.new(gestures.map.with_index {|gesture, index| gesture + multi_touch_gesture.gestures[index]})
        end

        def merge!(multi_touch_gesture)
          @gestures = merge(multi_touch_gesture).gestures
        end

        def to_json(*object)
          {
                query_timeout: @timeout.to_f,
                gestures: @gestures
          }.to_json(*object)
        end

        def query_string=(query_string)
          @gestures.each {|gesture| gesture.query_string=query_string}
        end

        def reset_query_string
          @gestures.each {|gesture| gesture.reset_query_string}
        end

        def offset=(offset)
          @gestures.each {|gesture| gesture.offset=offset}
        end

        def max_execution_time
          (@gestures.map {|gesture| gesture.max_execution_time}).max
        end
      end

      class Gesture
        attr_reader :touches

        def initialize(touches = [], query_string = nil)
          unless touches.is_a?(Array)
            touches = [touches]
          end

          @touches = []

          touches.each do |touch|
            @touches << Touch.new(touch)
          end

          @query_string = query_string
        end

        def from(touch)
          to(touch)
        end

        def to(touch)
          if touch.is_a?(Hash)
            touch = Touch.new(touch)
          end

          unless (last_touch = @touches.last).nil?
            touch.x ||= last_touch.x
            touch.y ||= last_touch.y
          end

          Gesture.new(@touches << touch, @query_string)
        end

        def +(gesture)
          Gesture.new(@touches + gesture.touches, @query_string)
        end

        def add_touch(touch)
          touches = @touches
          Gesture.new(touches << touch, @query_string)
        end

        def <<(touch)
          @touches << touch
        end

        def to_json(*object)
          {
                query_string: @query_string,
                touches: @touches
          }.to_json(*object)
        end

        def query_string=(query_string)
          @query_string = query_string
        end

        def reset_query_string
          touches.each {|touch| touch.query_string=nil}
        end

        def offset=(offset)
          @touches.each {|touch| touch.offset=offset}
        end

        def max_execution_time
          (@touches.map {|touch| touch.wait + touch.time}).reduce(:+)
        end

        def self.with_parameters(multi_touch_gesture, params={})
          multi_touch_gesture.query_string = params[:query_string] if params[:query_string]
          multi_touch_gesture.timeout = params[:timeout] if params[:timeout]

          multi_touch_gesture
        end

        def self.generate_tap(touch_hash)
          MultiTouchGesture.new(Gesture.new(Touch.new(touch_hash)))
        end

        def self.tap(opt={})
          touch = opt[:touch] || {}
          touch[:x] ||= (opt[:x] || 50)
          touch[:y] ||= (opt[:y] || 50)
          touch[:time] ||= (opt[:time] || 0.2)
          touch[:release] = touch[:release].nil? ? (opt[:release].nil? ? true : opt[:release]) : touch[:release]
          touch[:wait] ||= (opt[:wait] || 0)
          touch[:offset] ||= opt[:offset]

          generate_tap(touch)
        end

        def self.double_tap(opt={})
          self.tap(opt).merge(self.tap({wait: 0.1}.merge(opt)))
        end

        def self.generate_swipe(from_hash, to_hash, opt={})
          from_params = from_hash.merge(opt).merge(opt[:from] || {})
          to_params = {time: 0}.merge(to_hash).merge(opt[:to] || {})

          if opt[:flick]
            to_params.merge!(wait: 0)
          else
            to_params = {wait: 0.2}.merge(to_params)
          end

          self.tap({release: false}.merge(from_params)).merge(self.tap(to_params))
        end

        def self.swipe(direction, opt={})
          from = {x: 50, y: 50}
          to = {x: 50, y: 50}

          case direction
            when :left
              from[:x] = 90
              to[:x] = 10
            when :right
              from[:x] = 10
              to[:x] = 90
            when :up
              from[:y] = 90
              to[:y] = 10
            when :down
              from[:y] = 10
              to[:y] = 90
            else
              raise "Cannot swipe in #{direction}"
          end

          opt[:time] ||= 0.3

          generate_swipe(from, to, opt)
        end

        def self.generate_pinch_out(from_arr, to_arr, opt={})
          self.generate_swipe(from_arr[0], to_arr[0], opt) + self.generate_swipe(from_arr[1], to_arr[1], opt)
        end

        def self.pinch(direction, opt={})
          opt[:from] ||= []
          opt[:from][0] = (opt[:from][0] || {}).merge(opt)
          opt[:from][1] = (opt[:from][1] || {}).merge(opt)
          opt[:to] ||= []
          opt[:to][0] ||= {}
          opt[:to][1] ||= {}

          from = [{x: 40, y: 40}.merge(opt[:from][0]), {x: 60, y: 60}.merge(opt[:from][1])]
          to = [{x: 10, y: 10}.merge(opt[:to][0]), {x: 90, y: 90}.merge(opt[:to][1])]

          case direction
            when :out

            when :in
              from,to = to,from
            else
              raise "Cannot pinch #{direction}"
          end

          generate_pinch_out(from, to)
        end
      end

      class Touch
        attr_accessor :x, :y, :offset_x, :offset_y, :wait, :time, :release, :query_string

        def initialize(touch)
          if touch.is_a?(Touch)
            touch = touch.to_hash
          end

          touch[:offset] ||= {}
          touch[:offset_x] ||= touch[:offset][:x]
          touch[:offset_y] ||= touch[:offset][:y]

          @x = touch[:x]
          @y = touch[:y]
          @offset_x = touch[:offset_x] || 0
          @offset_y = touch[:offset_y] || 0
          @wait = touch[:wait] || 0
          @time = touch[:time] || 0
          @release = touch[:release].nil? ? false : touch[:release]
          @query_string = touch[:query_string]
        end

        def merge(touch)
          Touch.new(to_hash.merge(touch.to_hash))
        end

        def to_hash
          {
                x: @x,
                y: @y,
                offset_x: @offset_x || 0,
                offset_y: @offset_y || 0,
                wait: @wait.to_f,
                time: @time.to_f,
                release: @release,
                query_string: @query_string
          }
        end

        def to_json(object = Hash)
          to_hash.to_json(object)
        end

        def +(touch)
          hash = to_hash
          hash[:x] += touch.x
          hash[:y] += touch.y
          hash[:offset_x] += touch.offset_x
          hash[:offset_y] += touch.offset_y
          Touch.new(hash)
        end

        def -(touch)
          hash = to_hash
          hash[:x] -= touch.x
          hash[:y] -= touch.y
          hash[:offset_x] -= touch.offset_x
          hash[:offset_y] -= touch.offset_y
          Touch.new(hash)
        end

        def offset=(offset)
          @offset_x = offset[:x]
          @offset_y = offset[:y]
        end
      end
    end
  end
end
