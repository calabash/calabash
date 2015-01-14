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
    # @param [String] identifier a token that uniquely identifies the device.
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
    def install(params)
      if Managed.managed?
        Managed.install(params.merge({device: self}))
      else
        _install(params)
      end
    end

    # Do not modify
    def uninstall(params)
      if Managed.managed?
        Managed.uninstall(params.merge({device: self}))
      else
        _uninstall(params)
      end
    end

    # Do not modify
    def clear_app(params)
      if Managed.managed?
        Managed.clear_app(params.merge({device: self}))
      else
        _clear_app(params)
      end
    end

    class EnsureTestServerReadyTimeoutError < RuntimeError; end

    # Ensures the test server is ready
    #
    # @raises [RuntimeError] when the server does not respond
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
    def _install(params)
      abstract_method!
    end

    # @!visibility private
    def _uninstall(params)
      abstract_method!
    end

    # @!visibility private
    def _clear_app(params)
      abstract_method!
    end
  end
end
