module Calabash
  module IOS
    class Device < ::Calabash::Device

      attr_reader :run_loop
      attr_reader :start_options

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

      def self.default_identifier_for_application(application)
        if application.simulator_bundle?
          default_simulator_identifier
        elsif application.device_binary?
          default_physical_device_identifier
        else
          raise "Invalid application #{application} for iOS platform."
        end
      end

      def initialize(identifier, server)
        super

        Calabash::IOS::Device.expect_compatible_server_endpoint(identifier, server)
      end

      # TODO: Implement this method, remember to add unit tests
      def self.list_devices
        raise 'ni'
      end

      def test_server_responding?
        begin
          http_client.get(Calabash::HTTP::Request.new('version')).status.to_i == 200
        rescue Calabash::HTTP::Error => _
          false
        end
      end

      def to_s
        run_loop_device.to_s
      end

      def inspect
        run_loop_device.to_s
      end

      # @todo document install_app_on_device
      # @todo create a document describing ideviceinstaller implementation
      # noinspection RubyUnusedLocalVariable
      def install_app_on_physical_device(application, device_udid)
        logger.log('To install an ipa on a physical device, you must extend', :info)
        logger.log('Calabash::IOS::Device and implement the #install_app_on_device', :info)
        logger.log('method that uses a third-party tool to interact with physical devices.', :info)
        logger.log('For an example of an implementation using ideviceinstaller, see:', :info)
        logger.log('http://', :info)
        raise Calabash::AbstractMethodError, 'Device install_on_device must be implemented by you.'
      end

      # @todo document ensure_app_installed_on_device
      # @todo create a document describing ideviceinstaller implementation
      # noinspection RubyUnusedLocalVariable
      def ensure_app_installed_on_physical_device(application, device_udid)
        logger.log('To check if an app installed on a physical device, you must extend', :info)
        logger.log('Calabash::IOS::Device and implement the #ensure_app_installed_on_device', :info)
        logger.log('method that uses a third-party tool to interact with physical devices.', :info)
        logger.log('For an example of an implementation using ideviceinstaller, see:', :info)
        logger.log('http://', :info)
        raise Calabash::AbstractMethodError, 'Device ensure_app_installed_on_device must be implemented by you.'
      end

      private

      def _start_app(application, options={})
        if application.simulator_bundle?
          start_app_on_simulator(application, options)

        elsif application.device_binary?
          start_app_on_physical_device(application, options)
        else
          raise "Invalid application #{application} for iOS platform."
        end
      end

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
      def expect_valid_simulator_state_for_starting(application, run_loop_device)
        bridge = run_loop_bridge(run_loop_device, application)

        expect_app_installed(bridge)

        installed_app = Calabash::IOS::Application.new(bridge.fetch_app_dir)
        expect_matching_sha1s(installed_app, application)
      end

      def start_app_on_physical_device(application, options)
        # Cannot check to see if app is already installed.
        # Cannot check to see if app is different.

        @run_loop_device ||= Device.fetch_matching_physical_device(identifier)

        if @run_loop_device.nil?
          raise "Could not find a physical device with a UDID or name matching '#{identifier}'"
        end

        start_app_with_device_and_options(application, @run_loop_device, options)
        wait_for_server_to_start
      end

      def start_app_with_device_and_options(application, run_loop_device, user_defined_options)
        start_options = merge_start_options!(application, run_loop_device, user_defined_options)
        @run_loop = RunLoop.run(start_options)
      end

      def wait_for_server_to_start
        ensure_test_server_ready
        device_info = fetch_device_info
        extract_device_info!(device_info)
      end

      def _stop_app
        return true unless test_server_responding?

        parameters = default_stop_app_parameters

        begin
          http_client.get(request_factory('exit', parameters))
        rescue Calabash::HTTP::Error => e
          raise "Could send 'exit' to the app: #{e}"
        end
      end

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

      def default_stop_app_parameters
        {
              :post_resign_active_delay => 0.4,
              :post_will_terminate_delay => 0.4,
              :exit_code => 0
        }
      end

      def request_factory(route, parameters={})
        Calabash::HTTP::Request.new(route, parameters)
      end

      # RunLoop::Device is incredibly slow; don't call it more than once.
      def run_loop_device
        @run_loop_device ||= RunLoop::Device.device_with_identifier(identifier)
      end

      # Do not memoize this.  The Bridge initializer does a bunch of work to
      # prepare the environment for simctl actions.
      def run_loop_bridge(run_loop_simulator_device, application)
        RunLoop::Simctl::Bridge.new(run_loop_simulator_device, application.path)
      end

      def install_app_on_simulator(application, run_loop_device, run_loop_bridge = nil)
        begin

          if run_loop_bridge.nil?
            bridge = run_loop_bridge(run_loop_device, application)
          else
            bridge = run_loop_bridge
          end

          bridge.uninstall
          bridge.install
        rescue StandardError => e
          raise "Could not install #{application} on #{run_loop_device}: #{e}"
        end
      end

      def Device.fetch_matching_simulator(udid_or_name)
        sim_control = RunLoop::SimControl.new
        sim_control.simulators.detect do |sim|
          sim.instruments_identifier == udid_or_name ||
                sim.udid == udid_or_name
        end
      end

      def Device.fetch_matching_physical_device(udid_or_name)
        xctools = RunLoop::XCTools.new
        xctools.instruments(:devices).detect do |device|
          device.name == udid_or_name ||
                device.udid == udid_or_name
        end
      end

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

      def expect_app_installed(bridge)
        unless bridge.app_is_installed?
          raise 'App is not installed, you need to install it first.'
        end
        true
      end

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
    end
  end
end
