module Calabash
  module IOS

    # An iOS Device is an iOS Simulator or physical device.
    class Device < ::Calabash::Device

      require 'calabash/ios/runtime_attributes'

      # @todo Should these be public?
      # @todo If public, document!
      attr_reader :run_loop
      attr_reader :start_options

      # Returns the default simulator identifier.  The string that is return
      # can be used as an argument to `instruments`.
      #
      # You can set the default simulator identifier by setting the
      # `CAL_DEVICE_ID` environment variable.  If this value is not set, then
      # the default simulator identifier will indicate the highest supported
      # iPhone 5s Simulator SDK.  For example, when the active Xcode is 6.3,
      # the default value will be "iPhone 5s (8.3 Simulator)".
      #
      # @see Calabash::Environment::DEVICE_IDENTIFIER
      #
      # @return [String] An instruments-ready simulator identifier.
      # @raise [RuntimeError] When `CAL_DEVICE_ID` is set, this method will
      #   raise an error if no matching simulator can be found.
      def self.default_simulator_identifier
        identifier = Environment::DEVICE_IDENTIFIER

        if identifier.nil?
          RunLoop::Core.default_simulator
        else
          run_loop_device = Device.fetch_matching_simulator(identifier)
          if run_loop_device.nil?
            raise "Could not find a simulator with a UDID or name matching '#{identifier}'"
          end
          run_loop_device.instruments_identifier
        end
      end

      # Returns the default physical device identifier.  The string that is
      # return can be used as an argument to `instruments`.
      #
      # You can set the default physical device identifier by setting the
      # `CAL_DEVICE_ID` environment variable.  If this value is not set,
      # Calabash will try to detect available devices.
      # * If no devices are available, this method will raise an error.
      # * If more than one device is available, this method will raise an error.
      # * If only one device is available, this method will return the UDID
      #   of that device.
      #
      # @see Calabash::Environment::DEVICE_IDENTIFIER
      #
      # @return [String] An instruments-ready device identifier.
      # @raise [RuntimeError] When `CAL_DEVICE_ID` is set, this method will
      #   raise an error if no matching physical device can be found.
      # @raise [RuntimeError] When `CAL_DEVICE_ID` is not set and no physical
      #   devices are available.
      # @raise [RuntimeError] When `CAL_DEVICE_ID` is not set and more than one
      #   physical device is available.
      def self.default_physical_device_identifier
        identifier = Environment::DEVICE_IDENTIFIER

        if identifier.nil?
          connected_devices = RunLoop::XCTools.new.instruments(:devices)
          if connected_devices.empty?
            raise 'There are no physical devices connected.'
          elsif connected_devices.count > 1
            raise 'There is more than one physical devices connected.  Use CAL_DEVICE_ID to indicate which you want to connect to.'
          else
            connected_devices.first.instruments_identifier
          end
        else
          run_loop_device = Device.fetch_matching_physical_device(identifier)
          if run_loop_device.nil?
            raise "Could not find a physical device with a UDID or name matching '#{identifier}'"
          end
          run_loop_device.instruments_identifier
        end
      end

      # Returns the default identifier for an application.  If the application
      # is a simulator bundle (.app), the default simulator identifier is
      # returned. If the application is a device binary (.ipa), the default
      # physical device identifier is returned.
      #
      # @see Calabash::IOS::Device#default_simulator_identifier
      # @see Calabash::IOS::Device#default_physical_device_identifier
      #
      # @return [String] An instruments ready identifier based on whether the
      #  application is for a simulator or phyical device.
      # @raise [RuntimeError] If the application is not a .app or .ipa.
      def self.default_identifier_for_application(application)
        if application.simulator_bundle?
          default_simulator_identifier
        elsif application.device_binary?
          default_physical_device_identifier
        else
          raise "Invalid application #{application} for iOS platform."
        end
      end

      # Create a new iOS Device.
      #
      # @param [String] identifier The name or UDID of a simulator or physical
      #  device.
      # @param [Calabash::IOS::Server] server A representation of the embedded
      #  Calabash server.
      #
      # @return [Calabash::IOS::Device] A representation of an iOS Simulator or
      #  physical device.
      # @raise [RuntimeError] If the server points to localhost and the
      #  identifier is not for a simulator.
      #
      # @todo My inclination is to defer calling out to simctl or instruments
      # here to find the RunLoop::Device that matches identifier.  These are
      # very expensive calls.
      def initialize(identifier, server)
        super

        Calabash::IOS::Device.expect_compatible_server_endpoint(identifier, server)
      end

      # @!visibility private
      def test_server_responding?
        begin
          http_client.get(Calabash::HTTP::Request.new('version')).status.to_i == 200
        rescue Calabash::HTTP::Error => _
          false
        end
      end

      # @!visibility private
      def to_s
        if @run_loop_device
          run_loop_device.to_s
        else
          "#<iOS Device '#{identifier}'>"
        end
      end

      # @!visibility private
      def inspect
        to_s
      end

      # Calabash cannot manage apps on physical devices.  There are third-party
      # tools you can use to manage apps on devices.  Two popular tools are
      # ideviceinstaller and ios-deploy.  Both can be installed using homebrew.
      #
      # To integrate these tools, Calabash provides several methods for you to
      # override in your project.  In your `features/support/` directory, you
      # can patch Calabash::IOS::Device with your own implementation of these
      # methods.  The five methods to override are:
      #
      # 1. app_installed_on_physical_device?
      # 2. install_app_on_physical_device
      # 3. ensure_app_installed_on_physical_device
      # 4. clear_app_data_on_physical_device
      # 5. uninstall_app_on_physical_device
      #
      # ```
      #  # features/support/ideviceinstaller.rb
      #
      #  require 'fileutils'
      #  class Calabash::IOS::Device
      #
      #    def app_installed_on_physical_device?(application, device_udid)
      #      out = `/usr/local/bin/ideviceinstaller --udid #{device_udid} --list-apps`
      #      out.split(/\s/).include? application.identifier
      #    end
      #
      #    def install_app_on_physical_device(application, device_udid)
      #
      #      if app_installed_on_physical_device?(application, device_udid)
      #        uninstall_app_on_physical_device(application, device_udid)
      #      end
      #
      #      args =
      #            [
      #                  '--udid', device_udid,
      #                  '--install', application.path
      #            ]
      #
      #      log = FileUtils.touch('./ideviceinstaller.log')
      #      system('/usr/local/bin/ideviceinstaller', *args, {:out => log})
      #
      #      exit_code = $?
      #      unless exit_code == 0
      #        raise "Could not install the app (#{exit_code}).  See #{File.expand_path(log)}"
      #      end
      #      true
      #    end
      #
      #    def uninstall_app_on_physical_device(application, device_udid)
      #
      #      if app_installed_on_physical_device?(application, device_udid)
      #
      #        args =
      #              [
      #                    '--udid', device_udid,
      #                    '--uninstall', application.identifier
      #              ]
      #
      #        log = FileUtils.touch('./ideviceinstaller.log')
      #        system('/usr/local/bin/ideviceinstaller', *args, {:out => log})
      #
      #        exit_code = $?
      #        unless exit_code == 0
      #          raise "Could not uninstall the app (#{exit_code}).  See #{File.expand_path(log)}"
      #        end
      #      end
      #      true
      #    end
      #
      #    def ensure_app_installed_on_physical_device(application, device_udid)
      #      unless app_installed_on_physical_device?(application, device_udid)
      #        install_app_on_physical_device(application, device_udid)
      #      end
      #      true
      #    end
      #
      #    # The only way to clear the data is to uninstall the app.
      #    def clear_app_data_on_physical_device(application, device_udid)
      #      if app_installed_on_physical_device?(application, device_udid)
      #        install_app_on_physical_device(application, device_udid)
      #      end
      #      true
      #    end
      #  end
      # ```
      #
      # For a real-world example of a ruby wrapper around the ideviceinstaller
      # command-line tool, see https://github.com/calabash/ios-smoke-test-app.
      #
      # @see #app_installed_on_physical_device?
      # @see #install_app_on_physical_device
      # @see #ensure_app_installed_on_physical_device
      # @see #clear_app_data_on_physical_device
      # @see #uninstall_app_on_physical_device
      #
      # @see http://brew.sh/
      # @see https://github.com/libimobiledevice/ideviceinstaller
      # @see https://github.com/phonegap/ios-deploy
      # @see https://github.com/calabash/ios-smoke-test-app/blob/master/CalSmokeApp/features/support/ideviceinstaller.rb
      # @see https://github.com/blueboxsecurity/idevice
      #
      # For an real-world example of a ruby wrapper around the ideviceinstaller
      # tool, see /blob/master/CalSmokeApp/features/support/ideviceinstaller.rb
      #
      # @param [Calabash::IOS::Application] application The application to
      #  to install.  The important methods on application are `path` and
      #  `identifier`.
      # @param [String] device_udid The identifier of the device to install the
      #  application on.
      #
      # @return [Boolean] If the app was installed ont the device.
      #
      # @raise [Calabash::AbstractMethodError] If this method is not implemented
      #  by the user.
      def install_app_on_physical_device(application, device_udid)
        logger.log('To install an ipa on a physical device, you must extend', :info)
        logger.log('Calabash::IOS::Device and implement the #install_app_on_physical_device', :info)
        logger.log('method that using a third-party tool to interact with physical devices.', :info)
        logger.log('For an example of an implementation using ideviceinstaller, see:', :info)
        logger.log('https://github.com/calabash/ios-smoke-test-app.', :info)
        raise Calabash::AbstractMethodError,
              'Device install_app_on_physical_device must be implemented by you.'
      end

      # Calabash cannot manage apps on physical devices.  There are third-party
      # tools you can use to manage apps on devices.  Two popular tools are
      # ideviceinstaller and ios-deploy.  Both can be installed using homebrew.
      #
      # See the documentation for {Calabash::IOS::Device#install_app_on_physical_device}
      # for details about how to integrate a third-party tool into your project.
      #
      # @param [Calabash::IOS::Application] application The application to
      #  to install.  The important methods on application are `path` and
      #  `identifier`.
      # @param [String] device_udid The identifier of the device to install the
      #  application on.
      #
      # @return [Boolean] If the app is installed on the physical_device.
      #
      # @raise [Calabash::AbstractMethodError] If this method is not implemented
      #  by the user.
      def ensure_app_installed_on_physical_device(application, device_udid)
        logger.log('To check if an app installed on a physical device, you must extend', :info)
        logger.log('Calabash::IOS::Device and implement the #ensure_app_installed_on_device', :info)
        logger.log('method that using a third-party tool to interact with physical devices.', :info)
        logger.log('For an example of an implementation using ideviceinstaller, see:', :info)
        logger.log('https://github.com/calabash/ios-smoke-test-app.', :info)
        raise Calabash::AbstractMethodError,
              'Device ensure_app_installed_on_device must be implemented by you.'
      end

      # Calabash cannot manage apps on physical devices.  There are third-party
      # tools you can use to manage apps on devices.  Two popular tools are
      # ideviceinstaller and ios-deploy.  Both can be installed using homebrew.
      #
      # See the documentation for {Calabash::IOS::Device#install_app_on_physical_device}
      # for details about how to integrate a third-party tool into your project.
      #
      # @param [Calabash::IOS::Application] application The application to
      #  to install.  The important methods on application are `path` and
      #  `identifier`.
      # @param [String] device_udid The identifier of the device to install the
      #  application on.
      #
      # @return [Boolean] Return true if the application data was cleared.
      #
      # @raise [Calabash::AbstractMethodError] If this method is not implemented
      #  by the user.
      def clear_app_data_on_physical_device(application, device_udid)
        logger.log('To clear app data on a physical device, you must extend', :info)
        logger.log('Calabash::IOS::Device and implement the #clear_app_data_on_physical_device', :info)
        logger.log('method using a third-party tool to interact with physical devices.', :info)
        logger.log('For an example of an implementation using ideviceinstaller, see:', :info)
        logger.log('https://github.com/calabash/ios-smoke-test-app.', :info)
        raise Calabash::AbstractMethodError,
              'Device clear_app_data_on_physical_device must be implemented by you.'
      end

      # Calabash cannot manage apps on physical devices.  There are third-party
      # tools you can use to manage apps on devices.  Two popular tools are
      # ideviceinstaller and ios-deploy.  Both can be installed using homebrew.
      #
      # See the documentation for {Calabash::IOS::Device#install_app_on_physical_device}
      # for details about how to integrate a third-party tool into your project.
      #
      # @param [Calabash::IOS::Application] application The application to
      #  to install.  The important methods on application are `path` and
      #  `identifier`.
      # @param [String] device_udid The identifier of the device to install the
      #  application on.
      #
      # @return [Boolean] Return true if the application is installed on the
      #  device.
      #
      # @raise [Calabash::AbstractMethodError] If this method is not implemented
      #  by the user.
      def app_installed_on_physical_device?(application, device_udid)
        logger.log('To determine if an app is installed on a physical device, you must extend', :info)
        logger.log('Calabash::IOS::Device and implement the #app_installed_on_physical_device', :info)
        logger.log('method using a third-party tool to interact with physical devices.', :info)
        logger.log('For an example of an implementation using ideviceinstaller, see:', :info)
        logger.log('https://github.com/calabash/ios-smoke-test-app.', :info)
        raise Calabash::AbstractMethodError,
              'Device app_installed_on_physical_device? must be implemented by you.'
      end

      # Calabash cannot manage apps on physical devices.  There are third-party
      # tools you can use to manage apps on devices.  Two popular tools are
      # ideviceinstaller and ios-deploy.  Both can be installed using homebrew.
      #
      # See the documentation for {Calabash::IOS::Device#install_app_on_physical_device}
      # for details about how to integrate a third-party tool into your project.
      #
      # @param [Calabash::IOS::Application] application The application to
      #  to install.  The important methods on application are `path` and
      #  `identifier`.
      # @param [String] device_udid The identifier of the device to install the
      #  application on.
      #
      # @return [Boolean] Return true if the application was uninstalled.
      #
      # @raise [Calabash::AbstractMethodError] If this method is not implemented
      #  by the user.
      def uninstall_app_on_physical_device(application, device_udid)
        logger.log('To uninstall an ipa on a physical device, you must extend', :info)
        logger.log('Calabash::IOS::Device and implement the #uninstall_app_on_physical_device', :info)
        logger.log('method that using a third-party tool to interact with physical devices.', :info)
        logger.log('For an example of an implementation using ideviceinstaller, see:', :info)
        logger.log('https://github.com/calabash/ios-smoke-test-app.', :info)
        raise Calabash::AbstractMethodError,
              'Device uninstall_app_on_physical_device must be implemented by you.'
      end

      private

      attr_reader :runtime_attributes

      # @!visibility private
      def method_missing(name, *args, &block)
        # Need to check if runtime_info instance responds to a method, but
        # runtime_info will be nil until start_app has finished.
        #
        # Tried to use Forwardable, but the machinery for detecting the state
        # @runtime_attributes is nil was complicated.  It is also not clear yet if
        # will need/want to move the physical-device hooks out of this class
        # and to a delegate.
        #
        # This strategy requires that DeviceRuntimeInfo
        local_runtime_info = runtime_attributes || RuntimeAttributes.new(nil)

        if !local_runtime_info.methods.include?(name) && !methods.include?(name)
          super(name, *args, &block)
        end

        if runtime_attributes.nil?
          logger.log("The method '#{name}' is not available to IOS::Device until", :info)
          logger.log('the app has been launched with Calabash start_app.', :info)
          raise "The method '#{name}' can only be called after the app has been launched"
        end

        begin
          runtime_attributes.send(name, *args, &block)
        rescue => e
          raise  e.class, e
        end
      end

      # @!visibility private
      def _start_app(application, options={})
        if application.simulator_bundle?
          start_app_on_simulator(application, options)

        elsif application.device_binary?
          start_app_on_physical_device(application, options)
        else
          raise "Invalid application #{application} for iOS platform."
        end
      end

      # @!visibility private
      def start_app_on_simulator(application, options)
        @run_loop_device ||= Device.fetch_matching_simulator(identifier)

        if @run_loop_device.nil?
          raise "Could not find a simulator with a UDID or name matching '#{identifier}'"
        end

        expect_valid_simulator_state_for_starting(application, @run_loop_device)

        start_app_with_device_and_options(application, @run_loop_device, options)
        wait_for_server_to_start
      end

      # @todo No unit tests.
      # @!visibility private
      def expect_valid_simulator_state_for_starting(application, run_loop_device)
        bridge = run_loop_bridge(run_loop_device, application)

        expect_app_installed_on_simulator(bridge)

        installed_app = Calabash::IOS::Application.new(bridge.fetch_app_dir)
        expect_matching_sha1s(installed_app, application)
      end

      # @!visibility private
      def start_app_on_physical_device(application, options)
        # @todo Cannot check to see if app is already installed.
        # @todo Cannot check to see if app is different.

        @run_loop_device ||= Device.fetch_matching_physical_device(identifier)

        if @run_loop_device.nil?
          raise "Could not find a physical device with a UDID or name matching '#{identifier}'"
        end

        start_app_with_device_and_options(application, @run_loop_device, options)
        wait_for_server_to_start
      end

      # @!visibility private
      def start_app_with_device_and_options(application, run_loop_device, user_defined_options)
        start_options = merge_start_options!(application, run_loop_device, user_defined_options)
        @run_loop = RunLoop.run(start_options)
      end

      # @!visibility private
      def wait_for_server_to_start
        ensure_test_server_ready
        device_info = fetch_runtime_attributes
        @runtime_attributes = new_device_runtime_info(device_info)
      end

      # @!visibility private
      def new_device_runtime_info(device_info)
        RuntimeAttributes.new(device_info)
      end

      # @!visibility private
      def _stop_app
        begin
          if test_server_responding?
            parameters = default_stop_app_parameters
            request = request_factory('exit', parameters)
            http_client.get(request)
          else
            true
          end
        rescue Calabash::HTTP::Error => e
          raise "Could send 'exit' to the app: #{e}"
        ensure
          @runtime_attributes = nil
        end
      end

      # @!visibility private
      def _screenshot(path)
        request = request_factory('screenshot', {:path => path})
        begin
          screenshot = http_client.get(request)
          File.open(path, 'wb') { |file| file.write screenshot }
        rescue Calabash::HTTP::Error => e
          raise "Could not send 'screenshot' to the app: #{e}"
        end
        path
      end

      # @!visibility private
      def _install_app(application)
        if application.simulator_bundle?
          @run_loop_device ||= Device.fetch_matching_simulator(identifier)

          if @run_loop_device.nil?
            raise "Could not find a simulator with a UDID or name matching '#{identifier}'"
          end

          install_app_on_simulator(application, @run_loop_device)
        elsif application.device_binary?
          @run_loop_device ||= Device.fetch_matching_physical_device(identifier)

          if @run_loop_device.nil?
            raise "Could not find a physical device with a UDID or name matching '#{identifier}'"
          end
          install_app_on_physical_device(application, @run_loop_device.udid)
        else
          raise "Invalid application #{application} for iOS platform."
        end
      end

      # @!visibility private
      def _ensure_app_installed(application)
        if application.simulator_bundle?
          @run_loop_device ||= Device.fetch_matching_simulator(identifier)

          if @run_loop_device.nil?
            raise "Could not find a simulator with a UDID or name matching '#{identifier}'"
          end

          bridge = run_loop_bridge(@run_loop_device, application)

          if bridge.app_is_installed?
            true
          else
            install_app_on_simulator(application, @run_loop_device, bridge)
          end
        elsif application.device_binary?

          @run_loop_device ||= Device.fetch_matching_physical_device(identifier)

          if @run_loop_device.nil?
            raise "Could not find a physical device with a UDID or name matching '#{identifier}'"
          end

          ensure_app_installed_on_physical_device(application, @run_loop_device.udid)
        else
          raise "Invalid application #{application} for iOS platform."
        end
      end

      # @!visibility private
      def _clear_app_data(application)
        if application.simulator_bundle?
          @run_loop_device ||= Device.fetch_matching_simulator(identifier)

          if @run_loop_device.nil?
            raise "Could not find a simulator with a UDID or name matching '#{identifier}'"
          end

          bridge = run_loop_bridge(@run_loop_device, application)
          if bridge.app_is_installed?
            clear_app_data_on_simulator(application, @run_loop_device, bridge)
          else
            true
          end
        elsif application.device_binary?
          @run_loop_device ||= Device.fetch_matching_physical_device(identifier)

          if @run_loop_device.nil?
            raise "Could not find a physical device with a UDID or name matching '#{identifier}'"
          end

          clear_app_data_on_physical_device(application, @run_loop_device.udid)
        else
          raise "Invalid application #{application} for iOS platform."
        end
      end

      # @!visibility private
      def clear_app_data_on_simulator(application, run_loop_device, bridge)
        begin
          bridge.reset_app_sandbox
          true
        rescue e
          raise "Could not clear app data for #{application.identifier} on #{run_loop_device}: #{e}"
        end
      end

      # @!visibility private
      def _uninstall_app(application)
        if application.simulator_bundle?
          @run_loop_device ||= Device.fetch_matching_simulator(identifier)

          if @run_loop_device.nil?
            raise "Could not find a simulator with a UDID or name matching '#{identifier}'"
          end

          bridge = run_loop_bridge(@run_loop_device, application)
          if bridge.app_is_installed?
            uninstall_app_on_simulator(application, @run_loop_device, bridge)
          else
            true
          end
        elsif application.device_binary?
          @run_loop_device ||= Device.fetch_matching_physical_device(identifier)

          if @run_loop_device.nil?
            raise "Could not find a physical device with a UDID or name matching '#{identifier}'"
          end

          uninstall_app_on_physical_device(application, @run_loop_device.udid)
        else
          raise "Invalid application #{application} for iOS platform."
        end
      end

      # @!visibility private
      def uninstall_app_on_simulator(application, run_loop_device, bridge)
        begin
          bridge.uninstall
          true
        rescue e
          raise "Could not uninstall #{application.identifier} on #{run_loop_device}: #{e}"
        end
      end

      # @!visibility private
      def default_stop_app_parameters
        {
              :post_resign_active_delay => 0.4,
              :post_will_terminate_delay => 0.4,
              :exit_code => 0
        }
      end

      # @!visibility private
      def request_factory(route, parameters={})
        Calabash::HTTP::Request.new(route, parameters)
      end

      # @!visibility private
      # RunLoop::Device is incredibly slow; don't call it more than once.
      def run_loop_device
        @run_loop_device ||= RunLoop::Device.device_with_identifier(identifier)
      end

      # @!visibility private
      # Do not memoize this.  The Bridge initializer does a bunch of work to
      # prepare the environment for simctl actions.
      def run_loop_bridge(run_loop_simulator_device, application)
        RunLoop::Simctl::Bridge.new(run_loop_simulator_device, application.path)
      end

      # @!visibility private
      def install_app_on_simulator(application, run_loop_device, run_loop_bridge = nil)
        begin

          if run_loop_bridge.nil?
            bridge = run_loop_bridge(run_loop_device, application)
          else
            bridge = run_loop_bridge
          end

          bridge.uninstall
          bridge.install
        rescue e
          raise "Could not install #{application} on #{run_loop_device}: #{e}"
        end
      end

      # @!visibility private
      # Expensive!
      def Device.fetch_matching_simulator(udid_or_name)
        sim_control = RunLoop::SimControl.new
        sim_control.simulators.detect do |sim|
          sim.instruments_identifier == udid_or_name ||
                sim.udid == udid_or_name
        end
      end

      # @!visibility private
      # Very expensive!
      def Device.fetch_matching_physical_device(udid_or_name)
        xctools = RunLoop::XCTools.new
        xctools.instruments(:devices).detect do |device|
          device.name == udid_or_name ||
                device.udid == udid_or_name
        end
      end

      # @!visibility private
      # @todo Should this take a run_loop_device as an argument, rather than
      # an identifier?  Since calls to instruments and simctl are very
      # expensive we want to do as few of them as possible.  Maybe the
      # localhost? check should be done outside of this method?  If nothing
      # else, the result of Device.fetch_matching_simulator should be captured
      # in @run_loop_device.
      def self.expect_compatible_server_endpoint(identifier, server)
        if server.localhost?
          run_loop_device = Device.fetch_matching_simulator(identifier)
          if run_loop_device.nil?
            Logger.error("The identifier for this device is '#{identifier}'")
            Logger.error('which resolves to a physical device.')
            Logger.error("The server endpoint '#{server.endpoint}' is for an iOS Simulator.")
            Logger.error('Use CAL_ENDPOINT to specify the IP address of your device')
            Logger.error("Ex. $ CAL_ENDPOINT=http://10.0.1.2:37265 CAL_DEVICE_ID=#{identifier} be calabash ...")
            raise "Invalid device endpoint '#{server.endpoint}'"
          end
        end
      end

      # @!visibility private
      def expect_app_installed_on_simulator(bridge)
        unless bridge.app_is_installed?
          raise 'App is not installed, you need to install it first.'
        end
        true
      end

      # @!visibility private
      def expect_matching_sha1s(installed_app, new_app)
        unless installed_app.same_sha1_as?(new_app)
          logger.log('The installed application and the one under test are different.', :error)
          logger.log("Installed path: #{installed_app.path}", :error)
          logger.log("      New path: #{new_app.path}", :error)
          logger.log("Installed SHA1: #{installed_app.sha1}", :error)
          logger.log("      New SHA1: #{new_app.sha1}", :error)
          raise 'The installed app is different from the app under test.  You must install the new app before starting'
        end
        true
      end

      # @!visibility private
      # @todo Needs a bunch of work; see the argument munging in Calabash 0.x Launcher.
      def merge_start_options!(application, run_loop_device, options_from_user)
        default_options =
              {
                    :app => application.path,
                    :bundle_id => application.identifier,
                    :device_target => run_loop_device.instruments_identifier,
                    :uia_strategy => default_uia_strategy(run_loop_device)
              }
        @start_options = default_options.merge(options_from_user)
      end

      # @todo Move to run-loop!?!
      # @todo Not tested locally!
      def default_uia_strategy(run_loop_device)
        default = :preferences
        if run_loop_device.physical_device?
          # `setPreferencesValueForKey` on iOS 8 devices is broken in Xcode 6
          #
          # rdar://18296714
          # http://openradar.appspot.com/radar?id=5891145586442240
          # :preferences strategy is broken on iOS 8.0
          if run_loop_device.version >= RunLoop::Version.new('8.0')
            default = :host
          end
        end
        default
      end

      # @!visibility private
      def fetch_runtime_attributes
        request = request_factory('version')
        body = http_client.get(request).body
        begin
          JSON.parse(body)
        rescue TypeError, JSON::ParserError => _
          raise "Could not parse response '#{body}'; the app has probably crashed"
        end
      end
    end
  end
end
