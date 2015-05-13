describe Calabash::IOS::Device do
  it 'should inherit from Calabash::Device' do
    expect(Calabash::IOS::Device.ancestors).to include(Calabash::Device)
  end

  let(:identifier) {'my-identifier'}
  let(:server) {Calabash::Server.new(URI.parse('http://localhost:37265'), 37265)}
  let(:device) {Calabash::IOS::Device.new(identifier, server)}

  let(:dummy_device_class) {Class.new(Calabash::IOS::Device) {def initialize; @logger = Calabash::Logger.new; end}}
  let(:dummy_device) {dummy_device_class.new}
  let(:dummy_http_class) {Class.new(Calabash::HTTP::RetriableClient) {def initialize; end}}
  let(:dummy_http) {dummy_http_class.new}

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
        }.to raise_error
      end

      it 'returns the instruments identifier of the simulator' do
        stub_const('Calabash::Environment::DEVICE_IDENTIFIER', 'some identifier')
        sim = RunLoop::Device.new('fake', '8.0', 'some identifier')
        expect(Calabash::IOS::Device).to receive(:fetch_matching_simulator).and_return(sim)
        expect(Calabash::IOS::Device.default_simulator_identifier).to be == sim.instruments_identifier
      end
    end

    it 'when DEVICE_IDENTIFIER is nil, returns the default simulator' do
      stub_const('Calabash::Environment::DEVICE_IDENTIFIER', nil)
      expect(RunLoop::Core).to receive(:default_simulator).and_return('default sim')
      expect(Calabash::IOS::Device.default_simulator_identifier).to be == 'default sim'
    end
  end

  describe '#start_app' do
    it 'can launch an app' do
      expect(RunLoop).to receive(:run).and_return({})
      app = Calabash::Application.new('/path/to/my/app')
      expect(device).to receive(:ensure_test_server_ready).and_return true
      expect(device).to receive(:fetch_device_info).and_return({})
      expect(device).to receive(:extract_device_info!).and_return true
      expect(device.start_app(app)).to be_truthy
      expect(device.run_loop).to be_a_kind_of(Hash)
      expect(device.run_loop).to be == {}
    end
  end

  describe '#test_server_responding?' do
    let(:dummy_http_response_class) {Class.new {def status; end}}
    let(:dummy_http_response) {dummy_http_response_class.new}

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
    it 'does nothing if server is not responding' do
      expect(device).to receive(:test_server_responding?).and_return(false)
      expect(device.stop_app).to be_truthy
    end

    it "calls the server 'exit' route" do
      expect(device).to receive(:test_server_responding?).and_return(true)
      params = device.send(:default_stop_app_parameters)
      request = Calabash::HTTP::Request.new('exit', params)
      expect(device).to receive(:request_factory).and_return(request)
      expect(device.http_client).to receive(:get).with(request).and_return([])
      expect(device.stop_app).to be_truthy
    end

    it 'raises an exception if server cannot be reached' do
      expect(device).to receive(:test_server_responding?).and_return(true)
      expect(device.http_client).to receive(:get).and_raise(Calabash::HTTP::Error)
      expect { device.stop_app }.to raise_error
    end
  end

  describe '#screenshot' do
    it 'raise an exception if the server cannot be reached' do
      expect(device.http_client).to receive(:get).and_raise(Calabash::HTTP::Error)
      expect { device.screenshot('path') }.to raise_error
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
    let(:run_loop_device) { RunLoop::Device.new('denis', '8.3', 'udid') }
    describe 'raises an error when' do
      it 'is a physical device' do
        expect(device).to receive(:run_loop_device).and_return(run_loop_device)
        expect(run_loop_device).to receive(:simulator?).and_return(false)
        app = Calabash::Application.new('/path/to.app')
        expect { device.install_app(app) }.to raise_error(Calabash::AbstractMethodError)
      end

      it 'cannot install the application on the simulator' do
        expect(device).to receive(:run_loop_device).and_return(run_loop_device)
        expect(run_loop_device).to receive(:simulator?).and_return(true)
        app = Calabash::Application.new('/path/to.app')
        expect(device).to receive(:install_app_on_simulator).and_raise(StandardError)
        expect { device.install_app(app) }.to raise_error
      end
    end

    it 'installs the app' do
      expect(device).to receive(:run_loop_device).and_return(run_loop_device)
      expect(run_loop_device).to receive(:simulator?).and_return(true)
      app = Calabash::Application.new('/path/to.app')
      expect(device).to receive(:install_app_on_simulator).and_return('Shutdown')
      expect(device.install_app(app)).to be == 'Shutdown'
    end
  end
end
