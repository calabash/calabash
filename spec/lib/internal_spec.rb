describe Calabash::Internal do
  describe ".with_default_device" do
    it 'will take a block that is called with the current device, if it is set' do
      expected = :expected

      expect(Calabash).to receive(:default_device).and_return(expected)

      expect(Calabash::Internal.with_default_device {|device| device}).to eq(expected)
    end

    it 'will raise an error if the default device is not set' do
      expected_message = "The default device is not set. Set it using Calabash.default_device = ..."

      expect(Calabash).to receive(:default_device).and_return(nil)

      expect{Calabash::Internal.with_default_device {|device| device}}.to raise_error(RuntimeError, expected_message)
    end

    describe 'takes an option argument required os' do
      it 'will run if called with the correct device type' do
        default_device = Calabash::Android::Device.allocate

        expect(Calabash).to receive(:default_device).and_return(default_device)

        expect(Calabash::Internal.with_default_device(required_os: :android) {|device| device}).to eq(default_device)

        default_device = Calabash::IOS::Device.allocate

        expect(Calabash).to receive(:default_device).and_return(default_device)

        expect(Calabash::Internal.with_default_device(required_os: :ios) {|device| device}).to eq(default_device)
      end

      it 'will fail if not called with the correct device type' do
        default_device = Calabash::Android::Device.allocate
        expected_message = "The default device is not set to an iOS device, it is an Android device."

        expect(Calabash).to receive(:default_device).and_return(default_device)

        expect{Calabash::Internal.with_default_device(required_os: :ios) {|device| device}}.to raise_error(RuntimeError, expected_message)

        default_device = Calabash::IOS::Device.allocate
        expected_message = "The default device is not set to an Android device, it is an iOS device."

        expect(Calabash).to receive(:default_device).and_return(default_device)

        expect{Calabash::Internal.with_default_device(required_os: :android) {|device| device}}.to raise_error(RuntimeError, expected_message)
      end
    end
  end
end
