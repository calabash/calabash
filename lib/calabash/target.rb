module Calabash
  module TargetState
    require 'calabash/target_state/default_target_state'
  end

  # @!visibility private
  # Target represents a test-target, which is usually an application running on
  # a specific device. The target is set-up for the strategies used to
  # do automation. For example a Target could be the device with the serial
  # 'my-phone', and using a test-server on the port 7737, and using the
  # DeviceAgent.
  #
  # @todo For now, we just delegate to the device code.
  class Target < BasicObject
    attr_reader :device
    attr_reader :application

    def initialize(device, application)
      @device = device
      @application = application
    end

    def respond_to?(method)
      @device.respond_to?(method)
    end

    def method_missing(method, *args, &block)
      if @device.respond_to?(method)
        @device.send(method, *args, &block)
      else
        super.method_missing(method, *args, &block)
      end
    end
  end
end