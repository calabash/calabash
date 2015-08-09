module Calabash
  module IOS

    # Methods that describe the runtime attributes of the device under test.
    #
    # @note The key/value pairs in the Hash returned by #runtime_details are
    #  not stable and can change at any time.  Don't write tests that rely on
    #  specific keys or values in this Hash.  Instead, use the API methods
    #  defined in this class.
    module Runtime

      # Is the device under test a simulator?
      def simulator?
        Calabash::IOS::Device.default.simulator?
      end

      # Is the device under test a physical device?
      def physical_device?
        Calabash::IOS::Device.default.physical_device?
      end

      # Is the device under test an iPad?
      def ipad?
        Calabash::IOS::Device.default.device_family == 'iPad'
      end

      # Is the device under test an iPhone?
      def iphone?
        Calabash::IOS::Device.default.device_family == 'iPhone'
      end

      # Is the device under test an iPod?
      def ipod?
        Calabash::IOS::Device.default.device_family == 'iPod'
      end

      # Is the device under test an iPhone or iPod?
      def device_family_iphone?
        iphone? or ipod?
      end

      # Is the app that is being tested an iPhone app emulated on an iPad?
      #
      # An iPhone only app running on an iPad will be displayed in an emulated
      # mode.  Starting in iOS 7, such apps will always be launched in 2x mode.
      def iphone_app_emulated_on_ipad?
        Calabash::IOS::Device.default.iphone_app_emulated_on_ipad?
      end

      # Is the device under test have a 4 inch screen?
      def iphone_4in?
        Calabash::IOS::Device.default.form_factor == 'iphone 4in'
      end

      # Is the device under test an iPhone 6.
      def iphone_6?
        Calabash::IOS::Device.default.form_factor == 'iphone 6'
      end

      # Is the device under test an iPhone 6+?
      def iphone_6_plus?
        Calabash::IOS::Device.default.form_factor == 'iphone 6 +'
      end

      # Is the device under test an iPhone 3.5in?
      #
      # @note If the app under test is an iPhone app emulated on an iPad then
      #  the form factor will _always_ be 'iphone 3.5.in'.  If you need to
      #  branch on the actual device the app is running on, use the #ipad?
      #  method.
      #
      # @see #iphone_app_emulated_on_ipad?
      # @see #ipad?
      def iphone_35in?
        Calabash::IOS::Device.default.form_factor == 'iphone 3.5in'
      end

      # The screen dimensions and details about scale and sample rates.
      #
      # @example
      #  > app_screen_details
      #  => {
      #        :height => 1,
      #        :height => 1334,
      #        :width => 750,
      #        :scale => 2
      #      }
      #
      # @return [Hash] See the example.
      def app_screen_details
        Calabash::IOS::Device.default.screen_dimensions
      end

      # The version of iOS running on the test device.
      #
      # @example
      #  > ios_version.major
      #  > ios_version.minor
      #  > ios_version.patch
      #
      # @return [RunLoop::Version] A version object.
      def ios_version
        Calabash::IOS::Device.default.ios_version
      end

      # Is the device under test running iOS 6?
      def ios6?
        ios_version.major == 6
      end

      # Is the device under test running iOS 7?
      def ios7?
        ios_version.major == 7
      end

      # Is the device under test running iOS 8?
      def ios8?
        ios_version.major == 8
      end

      # Is the device under test running iOS 9?
      def ios9?
        ios_version.major == 9
      end

      # The version of the Calabash iOS Server running in the app.
      #
      # @example
      #  > server_version.major
      #  > server_version.minor
      #  > server_version.patch
      #
      # @return [RunLoop::Version] A version object.
      def server_version
        Calabash::IOS::Device.default.server_version
      end

      # Details about the version of the app under test.
      #
      # Will always contain these two keys:
      #
      #  * :bundle_version => CFBundleVersion
      #  * :short_version => CFBundleShortVersionString
      #
      # It may contain other key/value pairs.
      #
      # @return [Hash] Key/value pairs that describe the version of the app
      #  under test.
      def app_version_details
        hash = runtime_details
        {
              :bundle_version => hash['app_version'],
              :short_version => hash['short_version_string']
        }
      end

      # A hash of all the details about the runtime environment.
      #
      # @note The key/value pairs in this Hash are subject to change.  Don't
      #  write tests that rely on a specific key appearing in the Hash.  Use
      #  the methods in the {Calabash::IOS::Runtime} module instead.
      # @return[Hash] Key/value pairs that describe the runtime environment.
      def runtime_details
        Calabash::IOS::Device.default.runtime_details
      end
    end
  end
end
