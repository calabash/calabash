module Calabash
  module IOS
    class Device < ::Calabash::Device

      attr_reader :run_loop

      def self.default_simulator_identifier
        identifier = Environment::DEVICE_IDENTIFIER

        if identifier.nil?
          RunLoop::Core.default_simulator
        else
          run_loop_device = self.fetch_matching_simulator(identifier)
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
          run_loop_device = self.fetch_matching_physical_device(identifier)
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

      private

      def _start_app(application, options={})
        uia_strategy = :preferences
        if application.simulator_bundle?
          bridge = run_loop_bridge(application)

          expect_app_installed(bridge)

          installed_app = Calabash::IOS::Application.new(bridge.fetch_app_dir)
          expect_matching_sha1s(installed_app, application)
        elsif application.device_binary?
          # Would need hooks to ideviceinstaller to check if the app was already
          # installed.  We would also need information about the app version
          # to do a check to see if the installed and new ipas were the same.

          # `setPreferencesValueForKey` on iOS 8 devices is broken in Xcode 6
          #
          # rdar://18296714
          # http://openradar.appspot.com/radar?id=5891145586442240
          # :preferences strategy is broken on iOS 8.0
          if run_loop_device.version >= RunLoop::Version.new('8.0')
            uia_strategy = :host
          end
        else
          raise "Application '#{application}' is not a .app or .ipa"
        end

        default_opts =
            {
                  # @todo Can run-loop handle both an :app and :bundle_id?
                  :app => application.path,
                  :bundle_id => application.identifier,
                  :device_target => run_loop_device.instruments_identifier,
                  :uia_strategy => uia_strategy
            }

        launch_opts = default_opts.merge(options)
        @run_loop = RunLoop.run(launch_opts)
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
        target_device = run_loop_device
        if target_device.simulator?
          install_app_on_simulator(application, target_device)
        else
          install_app_on_device(application, target_device.udid)
        end
      end

      # @todo document install_app_on_device
      # @todo create a document describing ideviceinstaller implementation
      # noinspection RubyUnusedLocalVariable
      def install_app_on_device(application, device_udid)
        logger.log('To install an ipa on a physical device, you must extend', :info)
        logger.log('Calabash::IOS::Device and implement the #install_app_on_device', :info)
        logger.log('method that uses a third-party tool to interact with physical devices.', :info)
        logger.log('For an example of an implementation using ideviceinstaller, see:', :info)
        logger.log('http://', :info)
        raise Calabash::AbstractMethodError, 'Device install_on_device must be implemented by you.'
      end

      private

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
      def run_loop_bridge(application)
        RunLoop::Simctl::Bridge.new(run_loop_device, application.path)
      end

      def install_app_on_simulator(application, run_loop_device)
        begin
          bridge = run_loop_bridge(application)
          bridge.uninstall
          bridge.install
        rescue StandardError => e
          raise "Could not install #{application} on #{run_loop_device}: #{e}"
        end
      end

      def self.fetch_matching_simulator(udid_or_name)
        sim_control = RunLoop::SimControl.new
        sim_control.simulators.detect do |sim|
          sim.instruments_identifier == udid_or_name ||
                sim.udid == udid_or_name
        end
      end

      def self.fetch_matching_physical_device(udid_or_name)
        xctools = RunLoop::XCTools.new
        xctools.instruments(:devices).detect do |device|
          device.name == udid_or_name ||
                device.udid == udid_or_name
        end
      end

      def self.expect_compatible_server_endpoint(identifier, server)
        if server.localhost?
          run_loop_device = Calabash::IOS::Device.fetch_matching_simulator(identifier)
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
    end
  end
end
