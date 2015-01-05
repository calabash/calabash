module Calabash
  class Device
    include Utility

    class << self
      attr_accessor :default
    end

    def self.from_serial(serial)
      device = self.new

      device.instance_eval do
        @serial = serial
      end

      device
    end

    attr_reader :serial

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

    def install(args)
      abstract_method!
    end

    def uninstall(args)
      abstract_method!
    end
  end
end
