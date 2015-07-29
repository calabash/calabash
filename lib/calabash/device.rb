module Calabash
  class Device
    include Utility

    @@default = nil

    def self.default
      @@default
    end

    def self.default=(value)
      @@default = value
    end

    attr_reader :identifier, :server, :http_client, :logger

    # Create a new device.
    # @param [String] identifier A token that uniquely identifies the device.
    #   On iOS, this is the device UDID, or a simulator name or UDID returned by
    #   `$ xcrun instruments -s devices`.
    #   On Android, this is the serial of the device, emulator or simulator
    #   returned by `$ adb devices`.
    # @param [Server] server A server object.
    #
    # @return [Device] A device.
    def initialize(identifier, server, options={})
      @identifier = identifier
      @server = server
      @logger = options[:logger] || Calabash::Logger.new
      @http_client = HTTP::RetriableClient.new(server, options.fetch(:http_options, {}))
    end

    def change_server(new_server)
      @server = new_server
      @http_client.change_server(new_server)
    end

    # Start the application and the test server
    def start_app(path_or_application, options={})
      application = parse_path_or_app_parameters(path_or_application)

      _start_app(application, options)
    end

    # Shutdown the application and the test server
    def stop_app
      _stop_app
    end

    # @see Screenshot#screenshot
    def screenshot(name=nil)
      path = Screenshot.obtain_screenshot_path!(name)

      _screenshot(path)
    end

    def install_app(path_or_application)
      application = parse_path_or_app_parameters(path_or_application)

      _install_app(application)
    end

    def ensure_app_installed(path_or_application)
      application = parse_path_or_app_parameters(path_or_application)

      _ensure_app_installed(application)
    end

    def uninstall_app(path_or_application)
      application = parse_path_or_app_parameters(path_or_application)

      _uninstall_app(application)
    end

    def clear_app_data(path_or_application)
      application = parse_path_or_app_parameters(path_or_application)

      _clear_app_data(application)
    end

    def set_location(location)
      abstract_method!
    end

    def dump
      request = HTTP::Request.new('/dump')

      JSON.parse(http_client.get(request, timeout: 60).body)
    end

    # @!visibility private
    class EnsureTestServerReadyTimeoutError < RuntimeError; end

    # Ensures the test server is ready
    #
    # @raise [RuntimeError] Raises error when the server does not respond
    def ensure_test_server_ready(options={})
      begin
        Timeout.timeout(options.fetch(:timeout, 30), EnsureTestServerReadyTimeoutError) do
          loop do
            break if test_server_responding?
          end
        end
      rescue EnsureTestServerReadyTimeoutError => _
        raise 'Calabash server did not respond'
      end
    end

    # @!visibility private
    def test_server_responding?
      abstract_method!
    end

    # Performs a `tap` on the (first) view that matches `query`.
    # @see Calabash::Gestures#tap
    def tap(query, options={})
      Query.ensure_valid_query(query)

      gesture_options = options.dup
      gesture_options[:at] ||= {}
      gesture_options[:at][:x] ||= 50
      gesture_options[:at][:y] ||= 50
      gesture_options[:offset] ||= {}
      gesture_options[:offset][:x] ||= 0
      gesture_options[:offset][:y] ||= 0
      gesture_options[:timeout] ||= Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT

      _tap(query, gesture_options)
    end

    # Performs a `double_tap` on the (first) view that matches `query`.
    # @see Calabash::Gestures#double_tap
    def double_tap(query, options={})
      Query.ensure_valid_query(query)

      gesture_options = options.dup
      gesture_options[:at] ||= {}
      gesture_options[:at][:x] ||= 50
      gesture_options[:at][:y] ||= 50
      gesture_options[:offset] ||= {}
      gesture_options[:offset][:x] ||= 0
      gesture_options[:offset][:y] ||= 0
      gesture_options[:timeout] ||= Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT

      _double_tap(query, gesture_options)
    end

    # Performs a `long_press` on the (first) view that matches `query`.
    # @see Calabash::Gestures#long_press
    def long_press(query, options={})
      Query.ensure_valid_query(query)

      gesture_options = options.dup
      gesture_options[:at] ||= {}
      gesture_options[:at][:x] ||= 50
      gesture_options[:at][:y] ||= 50
      gesture_options[:offset] ||= {}
      gesture_options[:offset][:x] ||= 0
      gesture_options[:offset][:y] ||= 0
      gesture_options[:timeout] ||= Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT
      gesture_options[:duration] ||= 1

      _long_press(query, gesture_options)
    end

    # Performs a `pan` on the (first) view that matches `query`.
    # @see Calabash::Gestures#pan
    def pan(query, from, to, options={})
      Query.ensure_valid_query(query)

      ensure_valid_swipe_params(from, to)

      gesture_options = options.dup
      gesture_options[:duration] ||= 0.5
      gesture_options[:timeout] ||= Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT

      _pan(query, from, to, gesture_options)
    end

    # Performs a `pan` between two elements.
    # @see Calabash::Gestures#pan_between
    def pan_between(query_from, query_to, options={})
      Query.ensure_valid_query(query_from)
      Query.ensure_valid_query(query_to)

      gesture_options = options.dup
      gesture_options[:duration] ||= 1
      gesture_options[:timeout] ||= Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT

      _pan_between(query_from, query_to, gesture_options)
    end

    # Performs a `flick` on the (first) view that matches `query`.
    # @see Calabash::Gestures#flick
    def flick(query, from, to, options={})
      Query.ensure_valid_query(query)

      ensure_valid_swipe_params(from, to)

      gesture_options = options.dup
      gesture_options[:duration] ||= 0.5
      gesture_options[:timeout] ||= Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT

      _flick(query, from, to, gesture_options)
    end

    # @see Calabash::Gestures#pinch
    def pinch(direction, query, options={})
      Query.ensure_valid_query(query)

      unless direction == :out || direction == :in
        raise ArgumentError, "Invalid direction '#{direction}'"
      end

      gesture_options = options.dup
      gesture_options[:timeout] ||= Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT

      _pinch(direction, query, gesture_options)
    end

    # Enter `text` into the currently focused view.
    # @see Calabash::Text#enter_text
    def enter_text(text)
      abstract_method!
    end

    # @!visibility private
    def map_route(query, method_name, *method_args)
      abstract_method!
    end

    # @!visibility private
    def backdoor(method, *arguments)
      abstract_method!
    end

    private

    # @!visibility private
    def _start_app(application, options={})
      abstract_method!
    end

    # @!visibility private
    def _stop_app
      abstract_method!
    end

    # @!visibility private
    def _screenshot(path)
      abstract_method!
    end

    # @!visibility private
    def _install_app(application)
      abstract_method!
    end

    # @!visibility private
    def _ensure_app_installed(application)
      abstract_method!
    end

    # @!visibility private
    def _uninstall_app(application)
      abstract_method!
    end

    # @!visibility private
    def _clear_app_data(application)
      abstract_method!
    end

    # @!visibility private
    def parse_path_or_app_parameters(path_or_application)
      if path_or_application.is_a?(String)
        Calabash::Application.from_path(path_or_application)
      elsif path_or_application.is_a?(Calabash::Application)
        path_or_application
      else
        raise ArgumentError, "Expected a String or Calabash::Application, got #{path_or_application.class}"
      end
    end

    # @!visibility private
    def parse_identifier_or_app_parameters(identifier_or_application)
      if identifier_or_application.is_a?(String)
        identifier_or_application
      elsif identifier_or_application.is_a?(Calabash::Application)
        identifier_or_application.identifier
      else
        raise ArgumentError, "Expected a String or Calabash::Application, got #{identifier_or_application.class}"
      end
    end

    # @!visibility private
    def ensure_valid_swipe_params(from, to)
      unless from.is_a?(Hash)
        message = "Invalid 'from' (#{from}). Expected a hash"
        raise ArgumentError, message
      end

      unless from.include?(:x)
        message = 'No from[:x] given. Expected a number between 0 and 100'
        raise ArgumentError, message
      end

      unless from.include?(:y)
        message = 'No from[:y] given. Expected a number between 0 and 100'
        raise ArgumentError, message
      end

      unless (0..100).include?(from[:x])
        message = 'Invalid from[:x] given. Expected a number between 0 and 100'
        raise ArgumentError, message
      end

      unless (0..100).include?(from[:y])
        message = 'Invalid from[:y] given. Expected a number between 0 and 100'
        raise ArgumentError, message
      end

      unless to.is_a?(Hash)
        message = "Invalid 'to' (#{to}). Expected a hash"
        raise ArgumentError, message
      end

      unless to.include?(:x)
        message = 'No to[:x] given. Expected a number between 0 and 100'
        raise ArgumentError, message
      end

      unless to.include?(:y)
        message = 'No to[:y] given. Expected a number between 0 and 100'
        raise ArgumentError, message
      end

      unless (0..100).include?(to[:x])
        message = 'Invalid to[:x] given. Expected a number between 0 and 100'
        raise ArgumentError, message
      end

      unless (0..100).include?(to[:y])
        message = 'Invalid to[:y] given. Expected a number between 0 and 100'
        raise ArgumentError, message
      end
    end

    # @!visibility private
    def _tap(query, options={})
        abstract_method!
    end

    # @!visibility private
    def _double_tap(query, options={})
        abstract_method!
    end

    # @!visibility private
    def _long_press(query, options={})
        abstract_method!
    end

    # @!visibility private
    def _pan(query, from, to, options={})
        abstract_method!
    end

    # @!visibility private
    def _pan_between(query_from, query_to, options={})
      abstract_method!
    end

    # @!visibility private
    def _flick(query, from, to, options={})
      abstract_method!
    end

    # @!visibility private
    def _pinch(direction, query, options={})
      abstract_method!
    end

    # Do not keep a reference to this module
    def world_for_device
      @new_module = world_module.clone

      device = self

      @new_module.send(:define_singleton_method, :default_device) do
        device
      end

      @new_module
    end

    def world_module
      abstract_method!
    end
  end
end
