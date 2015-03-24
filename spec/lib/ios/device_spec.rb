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
end
