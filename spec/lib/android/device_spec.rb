describe Calabash::Android::Device do
  let(:dummy_device_class) {Class.new(Calabash::Android::Device) {def initialize; @logger = Calabash::Logger.new; end}}
  let(:dummy_device) {dummy_device_class.new}
  let(:dummy_http_class) {Class.new(Calabash::HTTP::RetriableClient) {def initialize; end}}
  let(:dummy_http) {dummy_http_class.new}

  before do
    allow(dummy_device).to receive(:http_client).and_return(dummy_http)
  end

  it 'should inherit from Calabash::Device' do
    expect(Calabash::Android::Device.ancestors).to include(Calabash::Device)
  end

  describe '#adb' do
    it 'should execute an adb command for the specified device' do
      serial = 'my-serial'
      command = 'my command'
      adb_path = 'my-path/adb'
      device = dummy_device_class.new
      device.instance_eval do
        @identifier = serial
      end

      allow(Calabash::Android::Environment).to receive(:adb_path).and_return(adb_path)
      expect(device).to receive(:'`').with("#{adb_path} -s #{serial} #{command}")

      device.adb(command)
    end
  end

  describe '#installed_apps' do
    it 'should be able to list installed applications' do
      allow(dummy_device).to receive(:adb).with('shell pm list packages').and_return("package:com.myapp2.app\npackage:com.android.androidapp\npackage:com.app\n")

      expect(dummy_device.installed_apps).to eq([
                                                    {id: 'com.myapp2.app'},
                                                    {id: 'com.android.androidapp'},
                                                    {id: 'com.app'}
                                                ])
    end
  end

  describe '#_clear_app' do
    it 'should clear the app using adb' do
      package = 'com.myapp.package'

      expect(dummy_device).to receive(:adb).with("shell pm clear #{package}")

      dummy_device.send(:_clear_app, package)
    end
  end

  describe '#test_server_responding?' do
    let(:dummy_http_response_class) {Class.new {def body; end}}
    let(:dummy_http_response) {dummy_http_response_class.new}

    it 'should return false when a Calabash:HTTP::Error is raised' do
      allow(dummy_device.http_client).to receive(:get).and_raise(Calabash::HTTP::Error)

      expect(dummy_device.test_server_responding?).to be == false
    end

    it 'should return false when ping does not respond pong' do
      allow(dummy_http_response).to receive(:body).and_return('not_pong')
      allow(dummy_device.http_client).to receive(:get).and_return(dummy_http_response)

      expect(dummy_device.test_server_responding?).to be == false
    end

    it 'should return true when ping responds pong' do
      allow(dummy_http_response).to receive(:body).and_return('pong')
      allow(dummy_device.http_client).to receive(:get).and_return(dummy_http_response)

      expect(dummy_device.test_server_responding?).to be == true
    end
  end
end