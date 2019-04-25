describe Calabash::Internal do
  describe '.with_current_target' do
    it 'will raise an error if the default device is not set' do
      expect(Calabash::Internal).to receive(:default_target_state).and_return(Class.new do
        def obtain_default_target
          raise 'message'
        end
      end.new)

      expected_message = 'message'

      expect{Calabash::Internal.with_current_target {|target| target}}.to raise_error(RuntimeError, expected_message)
    end

    it 'calls the given block with the default target, if default target is set' do
      expect(Calabash::Internal).to receive(:default_target_state).and_return(Class.new do
        def obtain_default_target
          return :set
        end
      end.new)

      expect(Calabash::Internal.with_current_target {|target| target}).to eq(:set)
    end

    describe 'takes an option argument required os' do
      it 'will run if called with the correct device type' do
        $default_device = Calabash::Android::Device.allocate

        allow(Calabash::Internal).to receive(:default_target_state).and_return(Class.new do
          def obtain_default_target
            return Calabash::Target.new($default_device, nil)
          end
        end.new)

        expect(Calabash::Internal.with_current_target(required_os: :android) {|target| target.device}).to eq($default_device)

        $default_device = Calabash::IOS::Device.allocate

        expect(Calabash::Internal.with_current_target(required_os: :ios) {|target| target.device}).to eq($default_device)
      end

      it 'will fail if not called with the correct device type' do
        $default_device = Calabash::Android::Device.allocate
        expected_message = "The default device is not set to an iOS device, it is an Android device."

        allow(Calabash::Internal).to receive(:default_target_state).and_return(Class.new do
          def obtain_default_target
            return Calabash::Target.new($default_device, nil)
          end
        end.new)

        expect{Calabash::Internal.with_current_target(required_os: :ios) {|target| target}}.to raise_error(RuntimeError, expected_message)

        $default_device = Calabash::IOS::Device.allocate
        expected_message = "The default device is not set to an Android device, it is an iOS device."

        expect{Calabash::Internal.with_current_target(required_os: :android) {|target| target}}.to raise_error(RuntimeError, expected_message)
      end
    end
  end
end
