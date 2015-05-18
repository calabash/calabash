module Calabash
  module IOS

    # This class provides information about the device under test that can
    # only be obtained at run time.
    class DeviceRuntimeInfo

      require 'run_loop'

      # @!visibility private
      GESTALT_IPHONE = 'iPhone'

      # @!visibility private
      GESTALT_IPAD = 'iPad'

      # @!visibility private
      GESTALT_IPHONE5 = '4-inch'

      # @!visibility private
      GESTALT_SIM_SYS = 'x86_64'

      # @!visibility private
      GESTALT_IPOD = 'iPod'

      # @!attribute [r] endpoint
      # The http address of this device.
      # @example
      #  http://192.168.0.2:37265
      # @return [String] an ip address with port number.
      attr_reader :endpoint

      # The device family of this device.
      #
      # @note Also know as the form factor.
      #
      # @example
      #  # will be one of
      #  iPhone
      #  iPod
      #  iPad
      #
      # @!attribute [r] device_family
      # @return [String] the device family
      attr_reader :device_family

      # @!visibility private
      # @attribute [r] simulator_details
      # @return [String] Additional details about the simulator.  If this device
      #  is a physical device, returns nil.
      attr_reader :simulator_details

      # The `major.minor.[.patch]` version of iOS that is running on this device.
      #
      # @example
      #  7.1
      #  6.1.2
      #  5.1.1
      #
      # @attribute [r] ios_version
      # @return [RunLoop::Version] The
      attr_reader :ios_version

      # The hardware architecture of this device.  Also known as the chip set.
      #
      # @example
      #  # simulator
      #  i386
      #  x86_64
      #
      # @example
      #  # examples from physical devices
      #  armv6
      #  armv7s
      #  arm64
      #
      # @attribute [r] system
      # @return [String] the hardware architecture of this device.
      #  this device.
      attr_reader :system

      # The version of the embedded Calabash server that is running in the
      # app under test on this device.
      #
      # @example
      #  0.9.168
      #  0.10.0.pre1
      #
      # @attribute [r] server_version
      # @return [RunLoop::Version] The major.minor.patch[.pre\d] version of the
      #   embedded Calabash server
      attr_reader :server_version

      # Indicates whether or not the app under test on this device is an
      #  iPhone-only app that is being emulated on an iPad.
      #
      # @note If the `1x` or `2x` button is visible, then the app is being
      #  emulated.
      #
      # @attribute [r] iphone_app_emulated_on_ipad
      # @return [Boolean] `true` if the app under test is emulated
      attr_reader :iphone_app_emulated_on_ipad

      # The form factor of this device.
      # @attribute [r] form_factor
      #
      # Will be one of:
      #   * ipad
      #   * iphone 4in
      #   * iphone 3.5in
      #   * iphone 6
      #   * iphone 6+
      #   * "" # if no information can be found.
      attr_reader :form_factor

      # For Calabash server version > 0.10.2 provides
      # device specific screen information.
      #
      # This is a hash of form:
      #  {
      #    :sample => 1,
      #    :height => 1334,
      #    :width => 750,
      #    :scale" => 2
      #  }
      #
      #
      # @attribute [r] screen_dimensions
      # @return [Hash] screen dimensions, scale and down/up sampling fraction.
      attr_reader :screen_dimensions

      # Creates a new instance of DeviceRuntimeInfo.
      # @param [Hash] device_info The result of calling the version route on
      #  on the server
      # @return [Calabash::IOS::DeviceRuntimeInfo] A new info object.
      def initialize(device_info)
        simulator_device = device_info['simulator_device']
        @system = device_info['system']
        if @system
          @device_family = @system.eql?(GESTALT_SIM_SYS) ? simulator_device : @system.split(/[\d,.]/).first
        end
        @simulator_details = device_info['simulator']

        if device_info['iOS_version']
          @ios_version = RunLoop::Version.new(device_info['iOS_version'])
        end

        @server_version = device_info['version']
        @iphone_app_emulated_on_ipad = device_info['iphone_app_emulated_on_ipad']
        @iphone_4in = device_info['4inch']
        screen_dimensions = device_info['screen_dimensions']
        if screen_dimensions
          @screen_dimensions = {}
          screen_dimensions.each_pair do |key,val|
            @screen_dimensions[key.to_sym] = val
          end
        end
      end

      # Is this device a simulator or physical device?
      # @return [Boolean] true if this device is a simulator
      def simulator?
        system.eql?(GESTALT_SIM_SYS)
      end

      # Is this device a device or simulator?
      # @return [Boolean] true if this device is a physical device
      def device?
        not simulator?
      end

      # Is this device an iPhone?
      # @return [Boolean] true if this device is an iphone
      def iphone?
        device_family.eql? GESTALT_IPHONE
      end

      # Is this device an iPod?
      # @return [Boolean] true if this device is an ipod
      def ipod?
        device_family.eql? GESTALT_IPOD
      end

      # Is this device an iPad?
      # @return [Boolean] true if this device is an ipad
      def ipad?
        device_family.eql? GESTALT_IPAD
      end

      # Is this device a 4in iPhone?
      # @return [Boolean] true if this device is a 4in iphone
      def iphone_4in?
        form_factor == 'iphone 4in'
      end

      # Is this device an iPhone 6?
      # @return [Boolean] true if this device is an iPhone 6
      def iphone_6?
        form_factor == 'iphone 6'
      end

      # Is this device an iPhone 6+?
      # @return [Boolean] true if this device is an iPhone 6+
      def iphone_6_plus?
        form_factor == 'iphone 6+'
      end

      # Is this device an iPhone 3.5in?
      # @return [Boolean] true if this device is an iPhone 3.5in?
      def iphone_35in?
        form_factor == 'iphone 3.5in'
      end

      # The major iOS version of this device.
      # @return [String] the major version of the OS
      def ios_major_version
        version_hash(ios_version)[:major_version]
      end

      # Is this device running iOS 8?
      # @return [Boolean] true if the major version of the OS is 8
      def ios8?
        ios_major_version.eql?('8')
      end

      # Is this device running iOS 7?
      # @return [Boolean] true if the major version of the OS is 7
      def ios7?
        ios_major_version.eql?('7')
      end

      # Is this device running iOS 6?
      # @return [Boolean] true if the major version of the OS is 6
      def ios6?
        ios_major_version.eql?('6')
      end

      # Is this device running iOS 5?
      # @return [Boolean] true if the major version of the OS is 5
      def ios5?
        ios_major_version.eql?('5')
      end

      # Is the app that is running an iPhone-only app emulated on an iPad?
      #
      # @note If the app is running in emulation mode, there will be a 1x or 2x
      #   scale button visible on the iPad.
      #
      # @return [Boolean] true if the app running on this devices is an
      #   iPhone-only app emulated on an iPad
      def iphone_app_emulated_on_ipad?
        iphone_app_emulated_on_ipad
      end
    end
  end
end
