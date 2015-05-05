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

  describe '#calabash_start_app' do
    it 'can launch an app' do
      expect(RunLoop).to receive(:run).and_return({})
      app = Calabash::Application.new('/path/to/my/app')
      expect(device).to receive(:ensure_test_server_ready).and_return true
      expect(device).to receive(:fetch_device_info).and_return({})
      expect(device).to receive(:extract_device_info!).and_return true
      expect(device.calabash_start_app(app)).to be_truthy
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

  describe '#calabash_stop_app' do
    it 'does nothing if server is not responding' do
      expect(device).to receive(:test_server_responding?).and_return(false)
      expect(device.calabash_stop_app).to be_truthy
    end

    it "calls the server 'exit' route" do
      expect(device).to receive(:test_server_responding?).and_return(true)
      params = device.send(:default_stop_app_parameters)
      request = Calabash::HTTP::Request.new('exit', params)
      expect(device).to receive(:request_factory).and_return(request)
      expect(device.http_client).to receive(:get).with(request).and_return([])
      expect(device.calabash_stop_app).to be_truthy
    end

    it 'raises an exception if server cannot be reached' do
      expect(device).to receive(:test_server_responding?).and_return(true)
      expect(device.http_client).to receive(:get).and_raise(Calabash::HTTP::Error)
      expect { device.calabash_stop_app }.to raise_error
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
end
