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

    attr_reader :identifier, :server, :http_client

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
      @logger = options[:logger] || Logger.new
      @http_client = HTTP::RetriableClient.new(server, options.fetch(:http_options, {}))
    end

    # Start the application and the test server
    #
    # @param [Application] application being tested.
    #   This has to be and instance of Android::Application
    #   when testing on an Android device.
    # @param [Hash] options
    def calabash_start_app(application, options={})
      abstract_method!
    end

    # Shutdown the application and the test server
    def calabash_stop_app
      abstract_method!
    end

    # Do not modify
    def install(path_or_application)
      application = parse_path_or_app_parameters(path_or_application)

      if Managed.managed?
        Managed.install(application, self)
      else
        _install(application)
      end
    end

    # Do not modify
    def uninstall(path_or_application)
      application = parse_path_or_app_parameters(path_or_application)

      if Managed.managed?
        Managed.uninstall(application, self)
      else
        _uninstall(application)
      end
    end

    # Do not modify
    def clear_app(path_or_application)
      application = parse_path_or_app_parameters(path_or_application)

      if Managed.managed?
        Managed.clear_app(application, self)
      else
        _clear_app(application)
      end
    end

    class EnsureTestServerReadyTimeoutError < RuntimeError; end

    # Ensures the test server is ready
    #
    # @raises [RuntimeError] Raises error when the server does not respond
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

    def test_server_responding?
      abstract_method!
    end

    private

    # @!visibility private
    def _install(application)
      abstract_method!
    end

    # @!visibility private
    def _uninstall(application)
      abstract_method!
    end

    # @!visibility private
    def _clear_app(application)
      abstract_method!
    end

    # @!visibility private
    def parse_path_or_app_parameters(path_or_application)
      if path_or_application.is_a?(String)
        Calabash::Application.new(path_or_application)
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
  end
end
