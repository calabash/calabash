describe Calabash::Android::Device do
  let(:dummy_device_class) {Class.new(Calabash::Android::Device) {def initialize; @logger = Calabash::Logger.new; end}}
  let(:dummy_device) {dummy_device_class.new}

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
end