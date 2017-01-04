module Calabash
  module IOS

    # An iOS Device is an iOS Simulator or physical device.
    # @!visibility private
    class Device < ::Calabash::Device

      include Calabash::IOS::PhysicalDeviceMixin
      include Calabash::IOS::Routes::ResponseParser
      include Calabash::IOS::Routes::HandleRouteMixin
      include Calabash::IOS::Routes::MapRouteMixin
      include Calabash::IOS::Routes::UIARouteMixin
      include Calabash::IOS::Routes::ConditionRouteMixin
      include Calabash::IOS::Routes::BackdoorRouteMixin
      include Calabash::IOS::Routes::PlaybackRouteMixin
      include Calabash::IOS::StatusBarMixin
      include Calabash::IOS::RotationMixin
      include Calabash::IOS::KeyboardMixin
      include Calabash::IOS::UIAKeyboardMixin
      include Calabash::IOS::UIAMixin
      include Calabash::IOS::IPadMixin
      include Calabash::IOS::GesturesMixin

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
          run_loop_device.instruments_identifier(RunLoop::SimControl.new.xcode)
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
          connected_devices = RunLoop::Instruments.new.physical_devices
          if connected_devices.empty?
            raise 'There are no physical devices connected.'
          elsif connected_devices.count > 1
            raise 'There is more than one physical devices connected.  Use CAL_DEVICE_ID to indicate which you want to connect to.'
          else
            connected_devices.first.instruments_identifier(RunLoop::SimControl.new.xcode)
          end
        else
          run_loop_device = Device.fetch_matching_physical_device(identifier)
          if run_loop_device.nil?
            raise "Could not find a physical device with a UDID or name matching '#{identifier}'"
          end
          run_loop_device.instruments_identifier(RunLoop::SimControl.new.xcode)
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
      #  application is for a simulator or physical device.
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

      # The device family of this device.
      #
      # @example
      #  # will be one of
      #  iPhone
      #  iPod
      #  iPad
      #
      # @return [String] the device family
      # @raise [RuntimeError] If the app has not been launched.
      def device_family
        # For iOS Simulators, this can be obtained by asking the run_loop_device
        # and analyzing the name of the device.  This  does not require the app
        # to be launched, but it is expensive (takes many seconds).

        # For physical devices, this can only be obtained using a third-party
        # tool like ideviceinfo or asking the server.
        expect_runtime_attributes_available(__method__)
        runtime_attributes.device_family
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
      #  form factor. If you need to detect an iPod use `device_family`. Also
      #  note that there are no iPod simulators.
      #
      # @return [String] The form factor of the device under test.
      # @raise [RuntimeError] If the app has not been launched.
      def form_factor
        # For iOS Simulators, this can be obtained by asking the run_loop_device
        # and analyzing the name of the device.  This  does not require the app
        # to be launched, but it is expensive (takes many seconds).

        # For physical devices, this can only be obtained using a third-party
        # tool like ideviceinfo or asking the server.
        expect_runtime_attributes_available(__method__)
        runtime_attributes.form_factor
      end

      # @!visibility private
      # The iOS version on the test device.
      #
      # @return [RunLoop::Version] The major.minor.patch[.pre\d] version of the
      #   iOS version on the device.
      def ios_version
        # Can be obtain by asking for a device's run_loop_device. This does not
        # require the app to be launched, but it is expensive
        # (takes many seconds).  run_loop_device is memoized so the expense
        # is only incurred 1x per device instance.

        # Can also be obtained by asking the server after the app is launched
        # on the device which would be cheaper.
        run_loop_device.version
      end

      # Is the app that is running an iPhone-only app emulated on an iPad?
      #
      # @note If the app is running in emulation mode, there will be a 1x or 2x
      #   scale button visible on the iPad.
      #
      # @return [Boolean] true if the app running on this devices is an
      #   iPhone-only app emulated on an iPad
      # @raise [RuntimeError] If the app has not been launched.
      def iphone_app_emulated_on_ipad?
        # It is possible to find this information on iOS Simulators without
        # launching the app.  It is not possible to find this information
        # when targeting a physical device unless a third-party tool is used.
        expect_runtime_attributes_available(__method__)
        runtime_attributes.iphone_app_emulated_on_ipad?
      end

      # Is this device a physical device?
      # @return [Boolean] Returns true if this device is a physical device.
      def physical_device?
        # Can be obtain by asking for a device's run_loop_device. This does not
        # require the app to be launched, but it is expensive
        # (takes many seconds).  run_loop_device is memoized so the expense
        # is only incurred 1x per device instance.

        # Can also be obtained by asking the server after the app is launched
        # on the device which would be cheaper.
        run_loop_device.physical_device?
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
      # @raise [RuntimeError] If the app has not been launched.
      def screen_dimensions
        # This can only be obtained at runtime because of iOS scaling and
        # sampling.
        expect_runtime_attributes_available(__method__)
        runtime_attributes.screen_dimensions
      end

      # The version of the embedded Calabash server that is running in the
      # app under test on this device.
      #
      # @return [RunLoop::Version] The major.minor.patch[.pre\d] version of the
      #   embedded Calabash server
      # @raise [RuntimeError] If the app has not been launched.
      def server_version
        # It is possible to find this information without launching the app but
        # it's probably best to ask the server for this information after the
        # app has launched.
        expect_runtime_attributes_available(__method__)
        runtime_attributes.server_version
      end

      # @!visibility private
      # A dump of runtime details.
      def runtime_details
        expect_runtime_attributes_available(__method__)
        @runtime_attributes.runtime_info
      end

      # Is this device a simulator?
      # @return [Boolean] Returns true if this device is a simulator.
      def simulator?
        # Can be obtain by asking for a device's run_loop_device. This does not
        # require the app to be launched, but it is expensive
        # (takes many seconds).  run_loop_device is memoized so the expense
        # is only incurred 1x per device instance.

        # Can also be obtained by asking the server after the app is launched
        # on the device which would be cheaper.
        run_loop_device.simulator?
      end

      # @see Calabash::Location#set_location
      def set_location(location)
        if physical_device?
          raise 'Setting the location is not supported on physical devices'
        end

        location_data =
            {
                'latitude' => location[:latitude],
                'longitude' => location[:longitude]
            }

        uia_serialize_and_call(:setLocation, location_data)
      end

      private

      attr_reader :runtime_attributes

      # @!visibility private
      def _start_app(application, options={})
        # If the application is already running, then stop the application first
        stop_app

        if application.simulator_bundle?
          start_app_on_simulator(application, options)

        elsif application.device_binary?
          start_app_on_physical_device(application, options)
        else
          raise "Invalid application #{application} for iOS platform."
        end

        # @todo Get the language code from the server!
        ensure_ipad_emulation_1x

        {
           :device => self,
           :application => application
        }
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

        installed_app = Calabash::IOS::Application.new(bridge.send(:installed_app_bundle_dir))
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
        @automator = Calabash::IOS::Automator::DeviceAgent.new(@run_loop)
      end

      # @!visibility private
      def wait_for_server_to_start(options={})
        ensure_test_server_ready(options)
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
          File.open(path, 'wb') { |file| file.write screenshot.body }
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
            installed_app = Calabash::IOS::Application.new(bridge.send(:installed_app_bundle_dir))

            if installed_app.same_sha1_as?(application)
              true
            else
              @logger.log("The installed app and the target app are different.", :info)
              @logger.log("   The target app has SHA: #{application.sha1}", :info)
              @logger.log("The installed app has SHA: #{installed_app.sha1}", :info)
              @logger.log("Installing the target app.", :info)
              install_app_on_simulator(application, @run_loop_device, bridge)
            end
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

          unless bridge.app_is_installed?
            raise "Cannot clear application data, the application '#{application.identifier}' is not installed"
          end

          installed_app = Calabash::IOS::Application.new(bridge.send(:installed_app_bundle_dir))

          unless installed_app.same_sha1_as?(application)
            raise "Cannot clear application data, the application '#{application.identifier}' installed is not the same as #{application.path}"
          end

          clear_app_data_on_simulator(application, @run_loop_device, bridge)
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
        rescue StandardError => e
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
          bridge.uninstall_app_and_sandbox
          true
        rescue => e
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
      # Do not memoize this.  The CoreSimulator initializer does a bunch of work to
      # prepare the environment for simctl actions.
      def run_loop_bridge(run_loop_simulator_device, application)
        run_loop_app = RunLoop::App.new(application.path)
        RunLoop::CoreSimulator.new(run_loop_simulator_device, run_loop_app, quit_sim_on_init: false)
      end

      # @!visibility private
      def install_app_on_simulator(application, run_loop_device, run_loop_bridge = nil)
        begin

          if run_loop_bridge.nil?
            bridge = run_loop_bridge(run_loop_device, application)
          else
            bridge = run_loop_bridge
          end

          bridge.uninstall_app_and_sandbox
          bridge.install
        rescue StandardError => e
          raise "Could not install #{application} on #{run_loop_device}: #{e}"
        end
      end

      # @!visibility private
      # Expensive!
      def Device.fetch_matching_simulator(udid_or_name)
        RunLoop::SimControl.new.simulators.detect do |sim|
          sim.instruments_identifier(RunLoop::SimControl.new.xcode) == udid_or_name ||
                sim.udid == udid_or_name
        end
      end

      # @!visibility private
      # Very expensive!
      def Device.fetch_matching_physical_device(udid_or_name)
        instruments = RunLoop::Instruments.new
        instruments.physical_devices.detect do |device|
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
            Logger.error("Ex. $ CAL_ENDPOINT=http://10.0.1.2:37265 CAL_DEVICE_ID=\"#{identifier}\" #{Calabash::Utility.bundle_exec_prepend}calabash ...")
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
      def uia_strategy_from_environment(run_loop_device)
        Environment::UIA_STRATEGY || default_uia_strategy(run_loop_device)
      end

      # @!visibility private
      # @todo Needs a bunch of work; see the argument munging in Calabash 0.x Launcher.
      def merge_start_options!(application, run_loop_device, options_from_user)
        strategy = uia_strategy_from_environment(run_loop_device)

        default_options =
              {
                    :app => application.path,
                    :bundle_id => application.identifier,
                    :device_target => run_loop_device.instruments_identifier(RunLoop::SimControl.new.xcode),
                    :uia_strategy => strategy,
                    :quit_sim_on_init => false
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

      # @!visibility private
      def expect_runtime_attributes_available(method_name)

        if runtime_attributes.nil?
          begin
            # Populates the @runtime_attributes
            wait_for_server_to_start({:timeout => 1.0})
          rescue Calabash::Device::EnsureTestServerReadyTimeoutError => _
            logger.log("The method '#{method_name}' is not available to IOS::Device until", :info)
            logger.log('the app has been launched with Calabash start_app.', :info)
            raise "The method '#{method_name}' can only be called after the app has been launched"
          end
        end

        true
      end

      def instruments_pid
        pids = RunLoop::Instruments.new.instruments_pids
        if pids
          pids.first
        else
          nil
        end
      end

      # Assumes the app is already running and the server can be reached.
      # @todo It might make sense to cache the uia_strategy on the _server_
      #  to avoid having to guess.
      def attach_to_run_loop(run_loop_device, uia_strategy)
        if uia_strategy
          strategy = uia_strategy
        else
          strategy = uia_strategy_from_environment(run_loop_device)
        end

        if strategy == :host
          @run_loop = RunLoop::HostCache.default.read
        else
          pid = instruments_pid
          @run_loop = {}
          @run_loop[:uia_strategy] = strategy
          @run_loop[:pid] = pid
        end

        # populate the @runtime_attributes
        wait_for_server_to_start({:timeout => 2})
        {
              :device => self,
              :uia_strategy => strategy
        }
      end

      def world_module
        Calabash::IOS
      end
    end
  end
end
