module Calabash
  module IOS

    # This class provides information about the device under test that can
    # only be obtained at run time.
    class RuntimeAttributes

      require 'run_loop'

      # Creates a new instance of DeviceRuntimeInfo.
      # @param [Hash] device_info The result of calling the version route on
      #  on the server
      # @return [Calabash::IOS::RuntimeAttributes] A new info object.
      def initialize(device_info)
        @device_info = device_info
      end


      # The device family of this device.
      #
      # @example
      #  # will be one of
      #  iPhone
      #  iPod
      #  iPad
      #
      # @return [String] the device family
      def device_family
        @device_family ||= lambda do
         return nil if device_info.nil?

         simulator_device = device_info['simulator_device']

         if simulator_device && !simulator_device.empty?
           simulator_device
         else
           system.split(/[\d,.]/).first
         end
        end
      end

      # The form factor of the device under test.
      #
      # Will be one of:
      #
      #   * ipad
      #   * iphone 4in
      #   * iphone 3.5in
      #   * iphone 6
      #   * iphone 6+
      #   * unknown # if no information can be found.
      #
      # @note iPod is not on this list for a reason!  An iPod has an iPhone
      #  form factor.
      #
      # @return [String] The form factor of the device under test.
      def form_factor
        @form_factor ||= lambda do
          return nil if device_info.nil?
          device_info['form_factor']
        end.call
      end

      # Is the app that is running an iPhone-only app emulated on an iPad?
      #
      # @note If the app is running in emulation mode, there will be a 1x or 2x
      #   scale button visible on the iPad.
      #
      # @return [Boolean] true if the app running on this devices is an
      #   iPhone-only app emulated on an iPad
      def iphone_app_emulated_on_ipad?
        @iphone_app_emulated_on_ipad ||= lambda do
          return nil if device_info.nil?
          device_info['iphone_app_emulated_on_ipad']
        end.call
      end


      # The iOS version on the test device.
      #
      # @return [RunLoop::Version] The major.minor.patch[.pre\d] version of the
      #   iOS version on the device.
      def ios_version
        @ios_version ||= lambda do
          return nil if device_info.nil?

          version_string = device_info['iOS_version']

          return nil if version_string.nil? || version_string.empty?

          RunLoop::Version.new(version_string)
        end.call
      end

      # Information about the runtime screen dimensions of the app under test.
      #
      # This is a hash of form:
      #
      # ```
      #    {
      #      :sample => 1,
      #      :height => 1334,
      #      :width => 750,
      #      :scale" => 2
      #    }
      # ```
      #
      # @return [Hash] screen dimensions, scale and down/up sampling fraction.
      def screen_dimensions
        @screen_dimensions ||= lambda do
          return nil if device_info.nil?
          screen_dimensions = device_info['screen_dimensions']
          @screen_dimensions = {}
          screen_dimensions.each_pair do |key,val|
            @screen_dimensions[key.to_sym] = val
          end
        end.call
      end

      # The version of the embedded Calabash server that is running in the
      # app under test on this device.
      #
      # @return [RunLoop::Version] The major.minor.patch[.pre\d] version of the
      #   embedded Calabash server
      def server_version
        @server_version ||= lambda do
          return nil if device_info.nil?

          version_string = device_info['version']

          return nil if version_string.nil? || version_string.empty?

          RunLoop::Version.new(version_string)
        end.call
      end

      private

      # @!visibility private
      # Details about the device.  For iOS Simulators, this will be x86_64,
      # which is not very helpful.   For physical devices, this will be the
      # internal Apple device name.  For example, the `iPhone 6+` will report
      # `iPhone7,1` and the `iPhone 5s` will report `iPhone 6`.
      #
      # @return [String] Information about the device under test.
      def system
        @system ||= lambda do
          return nil if device_info.nil?

          device_info['system']
        end.call
      end

      # @!visibility private
      # The hash passed to initialize.
      attr_reader :device_info

    end
  end
end
