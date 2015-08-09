Before do
  Calabash::Android::Environment.instance_eval do
    define_singleton_method(:adb_path) do
      File.join(File.dirname(__FILE__), 'fake_adb', 'fake_adb.rb')
    end
  end

  Calabash::Android::ADB.command('ADB-START', no_read: true)
  Calabash::Android::ADB.command('KILL-DEVICES')
end

After do
  Calabash::Android::ADB.command('ADB-STOP')
end

Before('@default_device_set') do
  Calabash::Android::ADB.command('ADD-DEVICE', 'my-device')

  identifier = Calabash::Android::Device.default_serial
  server = Calabash::Android::Server.default

  Calabash::Android::Device.default = Calabash::Android::Device.new(identifier, server)
end