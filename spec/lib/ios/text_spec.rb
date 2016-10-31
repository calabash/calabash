describe Calabash::IOS::Text do
  let(:device) do
    Class.new do
      def uia_type_string(_, _); ; end
      def docked_keyboard_visible?; false; end
      def undocked_keyboard_visible?; false; end
      def split_keyboard_visible?; false; end
      def text_from_keyboard_first_responder; ; end
      def uia_route(_); ; end
      def screenshot(_); end
      def enter_text(_, _); end
    end.new
  end

  let(:world) do
    Class.new do
      include Calabash::IOS

      def screenshot_embed; ; end
    end.new
  end

  before do
    allow(Calabash::Device).to receive(:default).at_least(:once).and_return device
  end

  it '#enter_text' do
    existing_text = 'existing'
    options = { existing_text: existing_text }
    expect(world).to receive(:wait_for_keyboard).and_return true
    expect(world).to receive(:text_from_keyboard_first_responder).and_return existing_text
    expect(device).to receive(:enter_text).with('text', options).and_return({})

    expect(world.enter_text('text')).to be_truthy
  end

  it '#enter_text_in' do
    expect(world).to receive(:tap).with('query').and_return([])
    expect(world).to receive(:enter_text).with('text').and_return({})

    expect(world._enter_text_in('query', 'text')).to be_truthy
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

  it '#text_of_first_responder' do
    expect(device).to receive(:text_from_keyboard_first_responder).and_return 'text'

    expect(world.text_from_keyboard_first_responder).to be == 'text'
  end

  describe '#keyboard_wait_timeout' do
    it 'returns timeout passed if it is non-nil' do
      expect(world.send(:keyboard_wait_timeout, 0.1)).to be == 0.1
    end

    it 'returns the default gesture w timeout otherwise' do
      time = 22

      stub_const('Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT', time)

      expect(world.send(:keyboard_wait_timeout, nil)).to be == 22
    end
  end
end
