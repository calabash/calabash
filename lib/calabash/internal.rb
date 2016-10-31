module Calabash
  # @!visibility private
  # Internal usage, NOT a public API
  module Internal
    def self.with_default_device(required_os: nil, &block)
      unless block
        raise ArgumentError, "No block given"
      end

      device = Calabash.default_device

      if device.nil?
        raise "The default device is not set. Set it using Calabash.default_device = ..."
      end

      if required_os
        required_class = nil
        required_type = nil
        current_type = nil

        case required_os
          when :ios
            required_class = Calabash::IOS::Device
            required_type = 'iOS'
          when :android
            required_class = Calabash::Android::Device
            required_type = 'Android'
          else
            raise ArgumentError, "Unknown OS '#{required_os}'"
        end

        if Calabash::Android.const_defined?(:Device, false) && device.is_a?(Calabash::Android::Device)
            current_type = 'Android'
        elsif Calabash::IOS.const_defined?(:Device, false) && device.is_a?(Calabash::IOS::Device)
            current_type = 'iOS'
        else
            current_type = 'unknown'
        end

        unless device.is_a?(required_class)
          raise "The default device is not set to an #{required_type} device, it is an #{current_type} device."
        end
      end

      block.call(device)
    end
  end
end