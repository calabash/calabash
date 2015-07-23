describe Calabash::IOS::Device do
  it 'should inherit from Calabash::Device' do
    expect(Calabash::IOS::Device.ancestors).to include(Calabash::Device)
  end

  let(:identifier) {'my-identifier'}
  let(:server) {Calabash::IOS::Server.new(URI.parse('http://localhost:37265'))}
  let(:device) {Calabash::IOS::Device.new(identifier, server)}

  let(:dummy_device_class) {Class.new(Calabash::IOS::Device) {def initialize; @logger = Calabash::Logger.new; end}}
  let(:dummy_device) {dummy_device_class.new}
  let(:dummy_http_class) {Class.new(Calabash::HTTP::RetriableClient) {def initialize; end}}
  let(:dummy_http) {dummy_http_class.new}

  let(:run_loop_device) do
    Class.new(RunLoop::Device) do
      def to_s ; '#< Mock RunLoop::Device>' ; end
      def inspect; to_s; end
    end.new('denis', '8.3', 'udid')
  end

  let(:app) { Calabash::IOS::Application.new(IOSResources.instance.app_bundle_path) }

  # Mock RunLoop::Simctl::Bridge
  let(:mock_bridge) do
    Class.new do
      def app_is_installed?; ; end
      def reset_app_sandbox; ; end
      def uninstall; ; end
      def install; ; end
    end.new
  end

  let(:runtime_attrs) do
    Class.new do
      def simulator?; ; end
      def device_family; ; end
      def form_factor; ;  end
      def iphone_app_emulated_on_ipad?; ; end
      def server_version; ; end
      def screen_dimensions; ; end
    end.new
  end

  before(:each) do
    allow(dummy_device).to receive(:http_client).and_return(dummy_http)
    allow_any_instance_of(Calabash::Application).to receive(:ensure_application_path)
  end

  describe '.default_simulator_identifier' do
    describe 'when DEVICE_IDENTIFIER is non-nil' do
      it 'raises an error if the simulator cannot be found' do
        stub_const('Calabash::Environment::DEVICE_IDENTIFIER', 'some identifier')
        expect(Calabash::IOS::Device).to receive(:fetch_matching_simulator).and_return(nil)
        expect {
          Calabash::IOS::Device.default_simulator_identifier
        }.to raise_error RuntimeError
      end

      it 'returns the instruments identifier of the simulator' do
        stub_const('Calabash::Environment::DEVICE_IDENTIFIER', 'some identifier')
        sim = RunLoop::Device.new('fake', '8.0', 'some identifier')
        expect(Calabash::IOS::Device).to receive(:fetch_matching_simulator).and_return(sim)
        expect(sim).to receive(:instruments_identifier).and_return 'fake (8.0 Simulator)'
        expect(Calabash::IOS::Device.default_simulator_identifier).to be == 'fake (8.0 Simulator)'
      end
    end

    it 'when DEVICE_IDENTIFIER is nil, returns the default simulator' do
      stub_const('Calabash::Environment::DEVICE_IDENTIFIER', nil)
      expect(RunLoop::Core).to receive(:default_simulator).and_return('default sim')
      expect(Calabash::IOS::Device.default_simulator_identifier).to be == 'default sim'
    end
  end

  describe '.default_physical_device_identifier' do
    describe 'when DEVICE_IDENTIFIER is non-nil' do
      it 'raises an error if the device cannot be found' do
        stub_const('Calabash::Environment::DEVICE_IDENTIFIER', 'some identifier')
        expect(Calabash::IOS::Device).to receive(:fetch_matching_physical_device).and_return(nil)
        expect {
          Calabash::IOS::Device.default_physical_device_identifier
        }.to raise_error RuntimeError
      end

      it 'returns the instruments identifier of the device' do
        stub_const('Calabash::Environment::DEVICE_IDENTIFIER', 'some identifier')
        p_device = RunLoop::Device.new('fake', '8.0', 'some identifier')
        expect(p_device).to receive(:physical_device?).at_least(:once).and_return(true)
        expect(Calabash::IOS::Device).to receive(:fetch_matching_physical_device).and_return(p_device)
        expect(Calabash::IOS::Device.default_physical_device_identifier).to be == p_device.instruments_identifier
      end
    end

    describe 'when DEVICE_IDENTIFIER is nil' do
      describe 'raises an error when' do
        it 'there are no connected devices' do
          stub_const('Calabash::Environment::DEVICE_IDENTIFIER', nil)
          allow_any_instance_of(RunLoop::XCTools).to receive(:instruments).with(:devices).and_return([])
          expect {
            Calabash::IOS::Device.default_physical_device_identifier
          }.to raise_error RuntimeError
        end

        it 'there is more than one connected device' do
          stub_const('Calabash::Environment::DEVICE_IDENTIFIER', nil)
          allow_any_instance_of(RunLoop::XCTools).to receive(:instruments).with(:devices).and_return([1, 2])
          expect {
            Calabash::IOS::Device.default_physical_device_identifier
          }.to raise_error RuntimeError
        end
      end

      it 'returns the device identifier of the connected device' do
        stub_const('Calabash::Environment::DEVICE_IDENTIFIER', nil)
        p_device = RunLoop::Device.new('fake', '8.0', 'some identifier')
        allow_any_instance_of(RunLoop::XCTools).to receive(:instruments).with(:devices).and_return([p_device])
        expect(p_device).to receive(:physical_device?).at_least(:once).and_return(true)
        expect(Calabash::IOS::Device.default_physical_device_identifier).to be == p_device.instruments_identifier
      end
    end
  end

  describe '.default_identifier_for_application' do
    it 'returns simulator identifier for .app' do
      expect(app).to receive(:simulator_bundle?).and_return(true)
      expect(Calabash::IOS::Device).to receive(:default_simulator_identifier).and_return('sim id')
      expect(Calabash::IOS::Device.default_identifier_for_application(app)).to be == 'sim id'
    end

    it 'returns device identifier for .ipa' do
      expect(app).to receive(:simulator_bundle?).and_return(false)
      expect(app).to receive(:device_binary?).and_return(true)
      expect(Calabash::IOS::Device).to receive(:default_physical_device_identifier).and_return('device id')
      expect(Calabash::IOS::Device.default_identifier_for_application(app)).to be == 'device id'
    end

    it 'raises an error if the application is not an .app or .ipa' do
      expect(app).to receive(:simulator_bundle?).and_return(false)
      expect(app).to receive(:device_binary?).and_return(false)
      expect {
        Calabash::IOS::Device.default_identifier_for_application(app)
      }.to raise_error RuntimeError
    end
  end

  describe '.expect_compatible_server_endpoint' do
    it 'server is not localhost do nothing' do
      expect(server).to receive(:localhost?).and_return(false)
      expect {
        Calabash::IOS::Device.send(:expect_compatible_server_endpoint, 'my id', server)
      }.not_to raise_error
    end

    describe 'server is localhost' do
      it 'raises an error if identifier does not resolve to a simulator' do
        expect(server).to receive(:localhost?).and_return(true)
        expect(Calabash::IOS::Device).to receive(:fetch_matching_simulator).and_return(nil)
        expect {
          Calabash::IOS::Device.send(:expect_compatible_server_endpoint, 'my id', server)
        }.to raise_error RuntimeError
      end

      it 'does nothing if the identifier resolves to a simulator' do
        expect(server).to receive(:localhost?).and_return(true)
        expect(Calabash::IOS::Device).to receive(:fetch_matching_simulator).and_return('a')
        expect {
          Calabash::IOS::Device.send(:expect_compatible_server_endpoint, 'my id', server)
        }.not_to raise_error
      end
    end
  end

  describe 'instance methods requiring expect_compatible_server_endpoint' do

    before do
      allow(Calabash::IOS::Device).to receive(:expect_compatible_server_endpoint).and_return(true)
    end

    describe 'abstract methods' do

      it '#app_installed_on_physical_device?' do
        expect {
          device.app_installed_on_physical_device?('app', 'device id')
        }.to raise_error Calabash::AbstractMethodError
      end

      it '#clear_app_data_on_physical_device' do
        expect {
          device.clear_app_data_on_physical_device('app', 'device id')
        }.to raise_error Calabash::AbstractMethodError
      end

      it '#install_app_on_physical_device' do
        expect {
          device.install_app_on_physical_device('app', 'device id')
        }.to raise_error Calabash::AbstractMethodError
      end

      it '#ensure_app_installed_on_physical_device' do
        expect {
          device.ensure_app_installed_on_physical_device('app', 'device id')
        }.to raise_error Calabash::AbstractMethodError
      end

      it '#uninstall_app_on_physical_device' do
        expect {
          device.uninstall_app_on_physical_device('app', 'device id')
        }.to raise_error Calabash::AbstractMethodError
      end
    end

    describe '#start_app' do
      let(:options) { {} }

      describe '#to_s' do
        it 'returns a string with identifier if @run_loop_device is nil' do
          device.instance_variable_set(:@run_loop_device, nil)
          expect(device.to_s).to be == "#<iOS Device 'my-identifier'>"
        end

        it 'calls run_loop_device.to_s if @run_loop_device is non-nil' do
          expect(run_loop_device).to receive(:to_s).and_return 'device'
          device.instance_variable_set(:@run_loop_device, run_loop_device)
          expect(device.to_s).to be == 'device'
        end
      end

      describe '#inspect' do
        it 'calls to_s' do
          expect(device).to receive(:to_s).and_return 'device'
          expect(device.inspect).to be == 'device'
        end
      end

      it 'raises an error if app is not an .ipa or .app' do
        expect(app).to receive(:simulator_bundle?).and_return false
        expect(app).to receive(:device_binary?).and_return false
        expect {
          device.start_app(app)
        }.to raise_error RuntimeError
      end

      it 'calls start_app_on_simulator when app is a simulator bundle' do
        expect(app).to receive(:simulator_bundle?).and_return true
        expect(device).to receive(:start_app_on_simulator).with(app, options).and_return true

        expect(device.start_app(app, options)).to be_truthy
      end

      it 'calls start_app_on_physical_device when app is a device binary' do
        expect(app).to receive(:simulator_bundle?).and_return false
        expect(app).to receive(:device_binary?).and_return true
        expect(device).to receive(:start_app_on_physical_device).with(app, options).and_return true

        expect(device.start_app(app, options)).to be_truthy
      end
    end

    describe '#test_server_responding?' do
      let(:dummy_http_response) { Class.new {def status; end}.new }

      it 'should return false when a Calabash:HTTP::Error is raised' do
        allow(dummy_device.http_client).to receive(:get).and_raise(Calabash::HTTP::Error)

        expect(dummy_device.test_server_responding?).to be == false
      end

      it 'should return false when the status code is not 200' do
        allow(dummy_http_response).to receive(:status).and_return('100')
        allow(dummy_device.http_client).to receive(:get).and_return(dummy_http_response)

        expect(dummy_device.test_server_responding?).to be == false
      end

      it 'should return true when ping responds pong' do
        allow(dummy_http_response).to receive(:status).and_return('200')
        allow(dummy_device.http_client).to receive(:get).and_return(dummy_http_response)

        expect(dummy_device.test_server_responding?).to be == true
      end
    end

    describe '#stop_app' do
      before { device.instance_variable_set(:@runtime_attributes, {}) }

      it 'clears the runtime_info if the server is not responding' do
        expect(device).to receive(:test_server_responding?).and_return(false)
        expect(device.stop_app).to be_truthy
        expect(device.send(:runtime_attributes)).to be == nil
      end

      it "calls the server 'exit' route" do
        expect(device).to receive(:test_server_responding?).and_return(true)
        params = device.send(:default_stop_app_parameters)
        request = Calabash::HTTP::Request.new('exit', params)
        expect(device).to receive(:request_factory).and_return(request)
        expect(device.http_client).to receive(:get).with(request).and_return([])

        expect(device.stop_app).to be_truthy
        expect(device.send(:runtime_attributes)).to be == nil
      end

      it 'raises an exception if server cannot be reached' do
        expect(device).to receive(:test_server_responding?).and_return(true)
        expect(device.http_client).to receive(:get).and_raise(Calabash::HTTP::Error)

        expect { device.stop_app }.to raise_error RuntimeError
        expect(device.send(:runtime_attributes)).to be == nil
      end
    end

    describe '#screenshot' do
      it 'raise an exception if the server cannot be reached' do
        expect(device.http_client).to receive(:get).and_raise(Calabash::HTTP::Error)

        expect { device.screenshot('path') }.to raise_error RuntimeError
      end

      it 'writes screenshot to a file' do
        path = File.join(Dir.mktmpdir, 'screenshot.png')
        expect(Calabash::Screenshot).to receive(:obtain_screenshot_path!).and_return(path)
        request = Calabash::HTTP::Request.new('exit', {path: path})
        expect(device).to receive(:request_factory).and_return(request)
        data = 'I am the screenshot!'
        expect(device.http_client).to receive(:get).with(request).and_return(data)

        expect(device.screenshot(path)).to be == path
        expect(File.read(path)).to be == data
      end
    end

    describe '#install_app' do
      it 'raises an error when application is not an .ipa or .app' do
        expect(app).to receive(:simulator_bundle?).at_least(:once).and_return false
        expect(app).to receive(:device_binary?).at_least(:once).and_return false

        expect {
          device.install_app(app)
        }.to raise_error RuntimeError
      end

      describe 'on a simulator' do
        it 'raises error when no matching simulator can be found' do
          expect(app).to receive(:simulator_bundle?).at_least(:once).and_return true
          expect(Calabash::IOS::Device).to receive(:fetch_matching_simulator).and_return nil

          expect {
            device.install_app(app)
          }.to raise_error RuntimeError
        end

        it 'calls install_app_on_simulator' do
          expect(app).to receive(:simulator_bundle?).at_least(:once).and_return true
          expect(Calabash::IOS::Device).to receive(:fetch_matching_simulator).and_return run_loop_device
          expect(device).to receive(:install_app_on_simulator).with(app, run_loop_device).and_return true

          expect(device.install_app(app)).to be_truthy
          expect(device.instance_variable_get(:@run_loop_device)).to be == run_loop_device
        end
      end

      describe 'on a device' do
        it 'raises an error when no matching device can be found' do
          expect(app).to receive(:simulator_bundle?).at_least(:once).and_return false
          expect(app).to receive(:device_binary?).at_least(:once).and_return true
          expect(Calabash::IOS::Device).to receive(:fetch_matching_physical_device).and_return nil

          expect {
            device.install_app(app)
          }.to raise_error RuntimeError
        end

        it 'calls install_app_on_device' do
          expect(app).to receive(:simulator_bundle?).at_least(:once).and_return false
          expect(app).to receive(:device_binary?).at_least(:once).and_return true
          expect(Calabash::IOS::Device).to receive(:fetch_matching_physical_device).and_return run_loop_device
          expect(device).to receive(:install_app_on_physical_device).with(app, run_loop_device.udid).and_return true

          expect(device.install_app(app)).to be_truthy
          expect(device.instance_variable_get(:@run_loop_device)).to be == run_loop_device
        end
      end
    end

    describe '#ensure_app_installed' do
      it 'raises an error when application is not an .ipa or .app' do
        expect(app).to receive(:simulator_bundle?).at_least(:once).and_return false
        expect(app).to receive(:device_binary?).at_least(:once).and_return false

        expect {
          device.ensure_app_installed(app)
        }.to raise_error RuntimeError
      end

      describe 'on a simulator' do
        it 'raises error when no matching simulator can be found' do
          expect(app).to receive(:simulator_bundle?).at_least(:once).and_return true
          expect(Calabash::IOS::Device).to receive(:fetch_matching_simulator).and_return nil

          expect {
            device.ensure_app_installed(app)
          }.to raise_error RuntimeError
        end

        it 'does nothing if app is already installed' do
          expect(app).to receive(:simulator_bundle?).at_least(:once).and_return true
          expect(Calabash::IOS::Device).to receive(:fetch_matching_simulator).and_return run_loop_device
          expect(device).to receive(:run_loop_bridge).and_return(mock_bridge)
          expect(mock_bridge).to receive(:app_is_installed?).and_return true

          expect(device.ensure_app_installed(app)).to be_truthy
          expect(device.instance_variable_get(:@run_loop_device)).to be == run_loop_device
        end

        it 'calls install_app_on_simulator if the app is not installed' do
          expect(app).to receive(:simulator_bundle?).at_least(:once).and_return true
          expect(Calabash::IOS::Device).to receive(:fetch_matching_simulator).and_return run_loop_device
          expect(device).to receive(:run_loop_bridge).and_return(mock_bridge)
          expect(mock_bridge).to receive(:app_is_installed?).and_return false
          expect(device).to receive(:install_app_on_simulator).with(app, run_loop_device, mock_bridge).and_return true

          expect(device.ensure_app_installed(app)).to be_truthy
          expect(device.instance_variable_get(:@run_loop_device)).to be == run_loop_device
        end

        describe 'on a device' do
          it 'raises an error when no matching device can be found' do
            expect(app).to receive(:simulator_bundle?).at_least(:once).and_return false
            expect(app).to receive(:device_binary?).at_least(:once).and_return true
            expect(Calabash::IOS::Device).to receive(:fetch_matching_physical_device).and_return nil

            expect {
              device.ensure_app_installed(app)
            }.to raise_error RuntimeError
          end

          it 'calls install_app_on_device' do
            expect(app).to receive(:simulator_bundle?).at_least(:once).and_return false
            expect(app).to receive(:device_binary?).at_least(:once).and_return true
            expect(Calabash::IOS::Device).to receive(:fetch_matching_physical_device).and_return run_loop_device
            expect(device).to receive(:ensure_app_installed_on_physical_device).with(app, run_loop_device.udid).and_return true

            expect(device.ensure_app_installed(app)).to be_truthy
            expect(device.instance_variable_get(:@run_loop_device)).to be == run_loop_device
          end
        end
      end
    end

    describe '#install_app_on_simulator' do
      it 'uninstalls and then installs' do
        expect(mock_bridge).to receive(:uninstall).and_return true
        expect(mock_bridge).to receive(:install).and_return true

        expect(device.send(:install_app_on_simulator, app, run_loop_device, mock_bridge)).to be_truthy
      end

      it 'creates a new mock_bridge if one is not provided' do
        expect(mock_bridge).to receive(:uninstall).and_return true
        expect(mock_bridge).to receive(:install).and_return true
        expect(device).to receive(:run_loop_bridge).with(run_loop_device, app).and_return mock_bridge

        expect(device.send(:install_app_on_simulator, app, run_loop_device)).to be_truthy
      end

      describe 'raises errors when' do
        it 'cannot create a new RunLoop::Simctl::Bridge' do
          expect(device).to receive(:run_loop_bridge).with(run_loop_device, app).and_raise

          expect {
            device.send(:install_app_on_simulator, app, run_loop_device)
          }.to raise_error RuntimeError
        end

        it 'calls bridge.uninstall and an exception is raised' do
          expect(mock_bridge).to receive(:uninstall).and_raise

          expect {
            device.send(:install_app_on_simulator, app, run_loop_device, mock_bridge)
          }.to raise_error RuntimeError
        end

        it 'calls bridge.install and an exception is raised' do
          expect(mock_bridge).to receive(:uninstall).and_return true
          expect(mock_bridge).to receive(:install).and_raise

          expect {
            device.send(:install_app_on_simulator, app, run_loop_device, mock_bridge)
          }.to raise_error RuntimeError
        end
      end
    end

    describe '#start_app_on_simulator' do
      it 'raises an error if no matching simulator is found' do
        expect(Calabash::IOS::Device).to receive(:fetch_matching_simulator).and_return nil

        expect {
          device.send(:start_app_on_simulator, app, {})
        }.to raise_error RuntimeError
      end

      it 'starts the app' do
        expect(Calabash::IOS::Device).to receive(:fetch_matching_simulator).and_return run_loop_device
        expect(device).to receive(:expect_valid_simulator_state_for_starting).with(app, run_loop_device).and_return true
        expect(device).to receive(:start_app_with_device_and_options).with(app, run_loop_device, {}).and_return true
        expect(device).to receive(:wait_for_server_to_start).and_return true

        expect(device.send(:start_app_on_simulator, app, {})).to be_truthy
      end
    end

    describe '#start_app_on_device' do
      it 'raises an error if no matching device is found' do
        expect(Calabash::IOS::Device).to receive(:fetch_matching_physical_device).and_return nil

        expect {
          device.send(:start_app_on_physical_device, app, {})
        }.to raise_error RuntimeError
      end

      it 'starts the app' do
        expect(Calabash::IOS::Device).to receive(:fetch_matching_physical_device).and_return run_loop_device
        expect(device).to receive(:start_app_with_device_and_options).with(app, run_loop_device, {}).and_return true
        expect(device).to receive(:wait_for_server_to_start).and_return true

        expect(device.send(:start_app_on_physical_device, app, {})).to be_truthy
      end
    end

    it '#start_app_with_device_and_options' do
      options = { :foo => :bar }
      run_loop = { :pid => 1234, :uia_strategy => :strategy }
      expect(device).to receive(:merge_start_options!).with(app, run_loop_device, options).and_return options
      expect(RunLoop).to receive(:run).with(options).and_return run_loop

      expect(device.send(:start_app_with_device_and_options, app, run_loop_device, options)).to be_truthy
      expect(device.instance_variable_get(:@uia_strategy)).to be == :strategy
      expect(device.instance_variable_get(:@run_loop)).to be == run_loop
    end

    it '#wait_for_server_to_start' do
      runtime_attrs = {:device => :info}
      expect(device).to receive(:ensure_test_server_ready).and_return true
      expect(device).to receive(:fetch_runtime_attributes).and_return runtime_attrs
      expect(device).to receive(:new_device_runtime_info).with(runtime_attrs).and_return runtime_attrs

      expect(device.send(:wait_for_server_to_start)).to be_truthy
      expect(device.send(:runtime_attributes)).to be == runtime_attrs
    end

    describe '#expect_app_installed_on_simulator' do
      it 'raises an error if the app is not installed' do
        expect(mock_bridge).to receive(:app_is_installed?).and_return(false)
        expect {
          device.send(:expect_app_installed_on_simulator, mock_bridge)
        }.to raise_error RuntimeError
      end

      it 'returns true if app is installed' do
        expect(mock_bridge).to receive(:app_is_installed?).and_return(true)
        expect(device.send(:expect_app_installed_on_simulator, mock_bridge)).to be_truthy
      end
    end

    describe 'expect_matching_sha1s#' do
      it 'raises an error if sha1s do not match' do
        app = Calabash::IOS::Application.new(IOSResources.instance.app_bundle_path)
        installed_app = Calabash::IOS::Application.new(IOSResources.instance.app_bundle_path)
        expect(installed_app).to receive(:sha1).at_least(:once).and_return('abcde')
        expect(app).to receive(:sha1).at_least(:once).and_return('fghij')
        expect {
          device.send(:expect_matching_sha1s, installed_app, app)
        }.to raise_error RuntimeError
      end

      it 'returns true if the sha1s match' do
        app = Calabash::IOS::Application.new(IOSResources.instance.app_bundle_path)
        installed_app = Calabash::IOS::Application.new(IOSResources.instance.app_bundle_path)
        expect(installed_app).to receive(:sha1).at_least(:once).and_return('abcde')
        expect(app).to receive(:sha1).at_least(:once).and_return('abcde')
        expect(device.send(:expect_matching_sha1s, installed_app, app)).to be_truthy
      end
    end

    describe '#merge_start_options!' do
      it 'sets the @start_options instance variable' do
        device.instance_variable_set(:@start_options, nil)
        expect(run_loop_device).to receive(:instruments_identifier).and_return 'instruments identifier'
        options = device.send(:merge_start_options!,
                              app,
                              run_loop_device,
                              {:foo => 'bar'})
        expect(options).to be_a_kind_of Hash
        expect(options[:foo]).to be == 'bar'
        expect(device.instance_variable_get(:@start_options)).to be == options
      end
    end

    it '#clear_app_data_on_physical_device' do
      expect {
        device.clear_app_data_on_physical_device(nil, nil)
      }.to raise_error Calabash::AbstractMethodError
    end

    describe '#clear_app_on_simulator' do
      it 'raises an error if app data cannot be cleared' do
        expect(mock_bridge).to receive(:reset_app_sandbox).and_raise
        expect {
          device.send(:clear_app_data_on_simulator, app, run_loop_device, mock_bridge)
        }.to raise_error RuntimeError
      end

      it 'resets the app sandbox' do
        expect(mock_bridge).to receive(:reset_app_sandbox).and_return true
        expect(device.send(:clear_app_data_on_simulator, app, run_loop_device, mock_bridge)).to be_truthy
      end
    end

    describe '#clear_app_data' do
      describe 'on simulators' do
        it 'raises an error if a matching simulator cannot be found' do
          expect(app).to receive(:simulator_bundle?).and_return true
          expect(Calabash::IOS::Device).to receive(:fetch_matching_simulator).and_return nil
          expect {
            device.send(:clear_app_data, app)
          }.to raise_error RuntimeError
        end

        it 'calls clear_app_on_simulator when the app is installed' do
          expect(app).to receive(:simulator_bundle?).and_return true
          expect(Calabash::IOS::Device).to receive(:fetch_matching_simulator).and_return run_loop_device
          expect(device).to receive(:run_loop_bridge).and_return mock_bridge
          expect(mock_bridge).to receive(:app_is_installed?).and_return true
          expect(device).to receive(:clear_app_data_on_simulator).with(app, run_loop_device, mock_bridge).and_return true

          expect(device.send(:clear_app_data, app)).to be_truthy
        end

        it 'does nothing if the app is not installed' do
          expect(app).to receive(:simulator_bundle?).and_return true
          expect(Calabash::IOS::Device).to receive(:fetch_matching_simulator).and_return run_loop_device
          expect(device).to receive(:run_loop_bridge).and_return mock_bridge
          expect(mock_bridge).to receive(:app_is_installed?).and_return false

          expect(device.send(:clear_app_data, app)).to be_truthy
        end
      end

      describe 'on devices' do
        it 'raises an error if a matching device cannot be found' do
          expect(app).to receive(:simulator_bundle?).and_return false
          expect(app).to receive(:device_binary?).and_return true
          expect(Calabash::IOS::Device).to receive(:fetch_matching_physical_device).and_return nil
          expect {
            device.send(:clear_app_data, app)
          }.to raise_error RuntimeError
        end

        it 'calls clear_app_on_physical_device' do
          expect(app).to receive(:simulator_bundle?).and_return false
          expect(app).to receive(:device_binary?).and_return true
          expect(Calabash::IOS::Device).to receive(:fetch_matching_physical_device).and_return run_loop_device
          expect(device).to receive(:clear_app_data_on_physical_device).with(app, run_loop_device.udid).and_return true

          expect(device.send(:clear_app_data, app)).to be_truthy
        end
      end
    end

    describe '#uninstall_app' do
      describe 'on simulators' do
        it 'raises an error if a matching simulator cannot be found' do
          expect(app).to receive(:simulator_bundle?).and_return true
          expect(Calabash::IOS::Device).to receive(:fetch_matching_simulator).and_return nil
          expect {
            device.send(:uninstall_app, app)
          }.to raise_error RuntimeError
        end

        it 'calls uninstall_app_on_simulator when the app is installed' do
          expect(app).to receive(:simulator_bundle?).and_return true
          expect(Calabash::IOS::Device).to receive(:fetch_matching_simulator).and_return run_loop_device
          expect(device).to receive(:run_loop_bridge).and_return mock_bridge
          expect(mock_bridge).to receive(:app_is_installed?).and_return true
          expect(device).to receive(:uninstall_app_on_simulator).with(app, run_loop_device, mock_bridge).and_return true

          expect(device.send(:uninstall_app, app)).to be_truthy
        end

        it 'does nothing if the app is not installed' do
          expect(app).to receive(:simulator_bundle?).and_return true
          expect(Calabash::IOS::Device).to receive(:fetch_matching_simulator).and_return run_loop_device
          expect(device).to receive(:run_loop_bridge).and_return mock_bridge
          expect(mock_bridge).to receive(:app_is_installed?).and_return false

          expect(device.send(:uninstall_app, app)).to be_truthy
        end
      end

      describe 'on devices' do
        it 'raises an error if a matching device cannot be found' do
          expect(app).to receive(:simulator_bundle?).and_return false
          expect(app).to receive(:device_binary?).and_return true
          expect(Calabash::IOS::Device).to receive(:fetch_matching_physical_device).and_return nil
          expect {
            device.send(:uninstall_app, app)
          }.to raise_error RuntimeError
        end

        it 'calls clear_app_on_physical_device' do
          expect(app).to receive(:simulator_bundle?).and_return false
          expect(app).to receive(:device_binary?).and_return true
          expect(Calabash::IOS::Device).to receive(:fetch_matching_physical_device).and_return run_loop_device
          expect(device).to receive(:uninstall_app_on_physical_device).with(app, run_loop_device.udid).and_return true

          expect(device.send(:uninstall_app, app)).to be_truthy
        end
      end
    end

    describe '#fetch_runtime_attributes' do
      let(:dummy_http_response) { Class.new {def body; '[]'; end}.new }
      let(:request) { Calabash::HTTP::Request.new('version') }

      before do
        expect(device).to receive(:request_factory).with('version').and_return(request)
        expect(device.http_client).to receive(:get).with(request).and_return dummy_http_response
      end

      it 'raises an error if response cannot be parsed to JSON' do
        expect(JSON).to receive(:parse).with('[]').and_raise
        expect {
          device.send(:fetch_runtime_attributes)
        }.to raise_error RuntimeError
      end

      it 'parses the body of the response to a ruby object' do
        expect(device.send(:fetch_runtime_attributes)).to be == []
      end
    end

    describe '#expect_runtime_attributes_available' do
      it 'raises an error when runtime_attributes are not available' do
        device.instance_variable_set(:@runtime_attributes, nil)
        expect {
          device.send(:expect_runtime_attributes_available, 'foo')
        }.to raise_error RuntimeError
      end

      it 'returns true if runtime_attributes are available' do
        device.instance_variable_set(:@runtime_attributes, 'anything')
        expect(device.send(:expect_runtime_attributes_available, 'foo')).to be == true
      end
    end

    describe '#device_family' do
      it 'raises an error if runtime_attributes are not set' do
        expect(device).to receive(:expect_runtime_attributes_available).and_raise
        expect do
          device.device_family
        end.to raise_error RuntimeError
      end

      it 'asks runtime_attributes for the value' do
        expect(device).to receive(:expect_runtime_attributes_available).and_return true
        expect(runtime_attrs).to receive(:device_family).and_return 'something'
        expect(device).to receive(:runtime_attributes).and_return runtime_attrs
        expect(device.device_family).to be == 'something'
      end
    end

    describe '#form_factor' do
      it 'raises an error if runtime_attributes are not set' do
        expect(device).to receive(:expect_runtime_attributes_available).and_raise
        expect do
          device.form_factor
        end.to raise_error RuntimeError
      end

      it 'asks runtime_attributes for the value' do
        expect(device).to receive(:expect_runtime_attributes_available).and_return true
        expect(runtime_attrs).to receive(:form_factor).and_return 'something'
        expect(device).to receive(:runtime_attributes).and_return runtime_attrs
        expect(device.form_factor).to be == 'something'
      end
    end

    it '#ios_version' do
      expect(device).to receive(:run_loop_device).and_return run_loop_device
      expect(device.ios_version).to be == run_loop_device.version
    end

    describe '#iphone_app_emulated_on_ipad?' do
      it 'raises an error if runtime_attributes are not set' do
        expect(device).to receive(:expect_runtime_attributes_available).and_raise
        expect do
          device.iphone_app_emulated_on_ipad?
        end.to raise_error RuntimeError
      end

      it 'asks runtime_attributes for the value' do
        expect(device).to receive(:expect_runtime_attributes_available).and_return true
        expect(runtime_attrs).to receive(:iphone_app_emulated_on_ipad?).and_return 'something'
        expect(device).to receive(:runtime_attributes).and_return runtime_attrs
        expect(device.iphone_app_emulated_on_ipad?).to be == 'something'
      end
    end

    it '#physical_device?' do
      expect(device).to receive(:run_loop_device).and_return run_loop_device
      expect(run_loop_device).to receive(:physical_device?).and_return 'something'
      expect(device.physical_device?).to be == 'something'
    end

    describe '#screen_dimensions' do
      it 'raises an error if runtime_attributes are not set' do
        expect(device).to receive(:expect_runtime_attributes_available).and_raise
        expect do
          device.screen_dimensions
        end.to raise_error RuntimeError
      end

      it 'asks runtime_attributes for the value' do
        expect(device).to receive(:expect_runtime_attributes_available).and_return true
        expect(runtime_attrs).to receive(:screen_dimensions).and_return 'something'
        expect(device).to receive(:runtime_attributes).and_return runtime_attrs
        expect(device.screen_dimensions).to be == 'something'
      end
    end

    describe '#server_version' do
      it 'raises an error if runtime_attributes are not set' do
        expect(device).to receive(:expect_runtime_attributes_available).and_raise
        expect do
          device.server_version
        end.to raise_error RuntimeError
      end

      it 'asks runtime_attributes for the value' do
        expect(device).to receive(:expect_runtime_attributes_available).and_return true
        expect(runtime_attrs).to receive(:server_version).and_return 'something'
        expect(device).to receive(:runtime_attributes).and_return runtime_attrs
        expect(device.server_version).to be == 'something'
      end
    end

    it '#simulator' do
      expect(device).to receive(:run_loop_device).and_return run_loop_device
      expect(run_loop_device).to receive(:simulator?).and_return 'something'
      expect(device.simulator?).to be == 'something'
    end

    describe '#uia_strategy_from_environment' do
      it 'respects the CAL_UIA_STRATEGY' do
        stub_const('Calabash::IOS::Environment::UIA_STRATEGY', :stubbed_value)

        expect(device.send(:uia_strategy_from_environment, run_loop_device)).to be == :stubbed_value
      end

      it 'finds the uia strategy based on device attributes' do
        stub_const('Calabash::IOS::Environment::UIA_STRATEGY', nil)
        expect(device).to receive(:default_uia_strategy).and_return(:based_on_device)

        expect(device.send(:uia_strategy_from_environment, run_loop_device)).to be == :based_on_device
      end
    end

    describe '#attach_to_run_loop' do
      describe 'passed a uia_strategy' do
        it ':host' do
          host_cache = Class.new do
            def read; {:uia_strategy => :host}; end
          end.new
          expect(RunLoop::HostCache).to receive(:default).and_return(host_cache)

          result = device.send(:attach_to_run_loop, run_loop_device, :host)
          expect(device.run_loop).to be == {:uia_strategy => :host}
          expect(device.uia_strategy).to be == :host
          expect(result).to be_truthy
        end

        it 'not :host' do
          expect(device).to receive(:instruments_pid).and_return(1)

          result = device.send(:attach_to_run_loop, run_loop_device, :not_host)
          expect(device.run_loop).to be == {:uia_strategy => :not_host, :pid => 1}
          expect(device.uia_strategy).to be == :not_host
          expect(result).to be_truthy
        end
      end

      describe 'not passed a uia_strategy' do
        it ':host' do
          host_cache = Class.new do
            def read; {:uia_strategy => :host}; end
          end.new
          expect(RunLoop::HostCache).to receive(:default).and_return(host_cache)
          expect(device).to receive(:uia_strategy_from_environment).and_return :host

          result = device.send(:attach_to_run_loop, run_loop_device, nil)
          expect(device.run_loop).to be == {:uia_strategy => :host}
          expect(device.uia_strategy).to be == :host
          expect(result).to be_truthy
        end

        it 'not :host' do
          expect(device).to receive(:instruments_pid).and_return(1)
          expect(device).to receive(:uia_strategy_from_environment).and_return :not_host

          result = device.send(:attach_to_run_loop, run_loop_device, nil)
          expect(device.run_loop).to be == {:uia_strategy => :not_host, :pid => 1}
          expect(device.uia_strategy).to be == :not_host
          expect(result).to be_truthy
        end
      end
    end
  end
end
