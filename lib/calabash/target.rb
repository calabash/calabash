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

    def start_app(options={})
      device.start_app(application, options)
    end

    def install_app
      device.install_app(application)
    end

    def clear_app_data
      device.clear_app_data(application)
    end

    def ensure_app_installed
      device.ensure_app_installed(application)
    end

    def uninstall_app
      device.uninstall_app(application)
    end

    def resume_app
      device.resume_app(application)
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