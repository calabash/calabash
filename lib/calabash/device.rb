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

    def install(args)
      abstract_method!
    end

    def uninstall(args)
      abstract_method!
    end
  end
end