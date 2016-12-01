describe Calabash::Android::Text do
  let(:dummy_class) {Class.new {include Calabash::Android}}
  let(:world) {dummy_class.new}

  let(:device) do
    Class.new(Calabash::Android::Device) do
      def initialize; end
    end.new
  end

  let(:target) do
    Class.new(Calabash::Target) do
    end.new(device, nil)
  end

  before do
    $_target = target

    allow(Calabash::Internal).to receive(:default_target_state).and_return (Class.new do
      def obtain_default_target
        $_target
      end
    end.new)
  end

  describe '#_keyboard_visible?' do
    it 'should ask the current target if the keyboard is visible' do
      expect(target).to receive(:keyboard_visible?).and_return("result")

      expect(world.send(:_keyboard_visible?)).to eq("result")
    end
  end
end