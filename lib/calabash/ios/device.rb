module Calabash
  module IOS
    class Device < ::Calabash::Device

      attr_reader :run_loop

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

      def _screenshot(path)
        request = request_factory('screenshot', {:path => path})
        begin
         screenshot = http_client.get(request)
         File.open(path, 'wb') { |file| file.write screenshot }
        rescue Calabash::HTTP::Error => _
          raise "Could not send 'screenshot' to the app: #{e}"
        end
        path
      end

      private

      def _start_app(application, options={})
        default_opts =
            {
                :app => application.path,
                :device_target => self.identifier,
                :uia_strategy => :preferences,
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
        rescue Calabash::HTTP::Error => _
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
      def install_app_on_device(application, device_udid)
        @logger.log('INFO: To install an ipa on a physical device, you must extend', :info)
        @logger.log('INFO: Calabash::IOS::Device and implement the #install_app_on_device', :info)
        @logger.log('INFO: method that uses a third-party tool to interact with physical devices.', :info)
        @logger.log('INFO: For an example of an implementation using ideviceinstaller, see:', :info)
        @logger.log('INFO:    http://', :info)
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

      def install_app_on_simulator(application, run_loop_device)
        begin
          bridge = RunLoop::Simctl::Bridge.new(run_loop_device, application.path)
          bridge.uninstall
          bridge.install
        rescue StandardError => e
          raise "Could not install #{application} on #{run_loop_device}: #{e}"
        end
      end
    end
  end
end
