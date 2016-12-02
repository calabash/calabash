module Calabash
  # @!visibility private
  # Internal usage, NOT a public API
  module Internal
    # @return [Calabash::TargetState::DefaultTargetState] The default target state
    #  that has been set
    def self.default_target_state
      @default_target_state
    end

    def self.default_target_state=(default_target_state)
      @default_target_state = default_target_state
    end

    # @!visibility private
    # Message that is saved when detecting the default device
    def self.default_device_setup_message
      @default_device_setup_message
    end

    # @!visibility private
    def self.default_device_setup_message=(value)
      @default_device_setup_message = value
    end

    # @!visibility private
    # Sets up the default device using `&block`, saves error if it fails
    def self.save_setup_default_device_error(&block)
      begin
        block.call
      rescue => e
        self.default_device_setup_message = e.message
      end
    end

    # @!visibility private
    # Message that is saved when detecting the default application
    def self.default_application_setup_message
      @default_application_setup_message
    end

    # @!visibility private
    def self.default_application_setup_message=(value)
      @default_application_setup_message = value
    end

    # @!visibility private
    # Sets up the default device using `&block`, saves error if it fails
    def self.save_setup_default_application_error(&block)
      begin
        block.call
      rescue => e
        self.default_application_setup_message = e.message
      end
    end

    def self.with_current_target(required_os: nil, &block)
      unless block
        raise ArgumentError, "No block given"
      end

      target = default_target_state.obtain_default_target

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

        if Calabash::Android.const_defined?(:Device, false) && target.device.is_a?(Calabash::Android::Device)
          current_type = 'Android'
        elsif Calabash::IOS.const_defined?(:Device, false) && target.device.is_a?(Calabash::IOS::Device)
          current_type = 'iOS'
        else
          current_type = 'unknown'
        end

        unless target.device.is_a?(required_class)
          raise "The default device is not set to an #{required_type} device, it is an #{current_type} device."
        end
      end

      block.call(target)
    end
  end
end