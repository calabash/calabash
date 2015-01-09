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

    attr_reader :identifier, :server

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

    private

    # @!visibility private
    def _install(params)
      abstract_method!
    end

    # @!visibility private
    def _uninstall(params)
      abstract_method!
    end
  end
end
