describe Calabash::IOS::API do

  let(:device) do
    Class.new do
      def docked_keyboard_visible?; false; end
      def undocked_keyboard_visible?; false; end
      def split_keyboard_visible?; false; end
      def wait_for_keyboard(_); ; end
      def text_from_keyboard_first_responder; ; end
    end.new
  end

  let(:world) do
    Class.new do
      require 'calabash/ios/api'
      include Calabash::IOS::API
      def to_s
        '#<Cucumber World>'
      end

      def inspect
        to_s
      end
    end.new
  end

  before do
    expect(Calabash::IOS::Device).to receive(:default).at_least(:once).and_return device
  end

  it '#docked_keyboard_visible?' do
    expect(device).to receive(:docked_keyboard_visible?).and_return 'true'

    expect(world.docked_keyboard_visible?).to be == 'true'
  end

  it '#undocked_keyboard_visible?' do
    expect(device).to receive(:undocked_keyboard_visible?).and_return 'true'

    expect(world.undocked_keyboard_visible?).to be == 'true'
  end

  it '#split_keyboard_visible?' do
    expect(device).to receive(:split_keyboard_visible?).and_return 'true'

    expect(world.split_keyboard_visible?).to be == 'true'
  end

  describe '#keyboard_visible?' do
    it 'returns false if no keyboard is visible' do
      expect(world.keyboard_visible?).to be_falsey
    end

    describe 'returns true if any keyboard is visible' do
      it 'docked keyboard' do
        expect(device).to receive(:docked_keyboard_visible?).and_return true

        expect(world.keyboard_visible?).to be_truthy
      end

      it 'undocked keyboard' do
        expect(device).to receive(:undocked_keyboard_visible?).and_return true

        expect(world.keyboard_visible?).to be_truthy
      end

      it 'split keyboard' do
        expect(device).to receive(:split_keyboard_visible?).and_return true

        expect(world.keyboard_visible?).to be_truthy
      end
    end
  end

  it '#wait_for_keyboard' do
    expect(device).to receive(:wait_for_keyboard).with(5).and_return 'true'

    expect(world.wait_for_keyboard(5)).to be == 'true'
  end

  it '#text_of_first_responder' do
    expect(device).to receive(:text_from_keyboard_first_responder).and_return 'text'

    expect(world.text_from_keyboard_first_responder).to be == 'text'
  end
end
