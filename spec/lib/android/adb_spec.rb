describe Calabash::Android::ADB do
  describe '#command' do
    it 'can execute the given command' do
      command = 'my command'
      adb_path = 'my-path/adb'

      allow(Calabash::Android::Environment).to receive(:adb_path).and_return(adb_path)
      expect(Calabash::Android::ADB).to receive(:'`').with("#{adb_path} #{command}")

      Calabash::Android::ADB.command(command)
    end

    it 'can execute the given command with a serial' do
      serial = 'my-serial'
      command = 'my command'
      adb_path = 'my-path/adb'

      allow(Calabash::Android::Environment).to receive(:adb_path).and_return(adb_path)
      expect(Calabash::Android::ADB).to receive(:'`').with("#{adb_path} -s #{serial} #{command}")

      Calabash::Android::ADB.command(command, serial)
    end
  end
end
