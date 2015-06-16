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
    end.new
  end

  let(:world) do
    Class.new do
      require 'calabash/ios'
      include Calabash::IOS

      def screenshot_embed; ; end
    end.new
  end

  let(:short_timeout) do
    if Luffa::Environment.travis_ci?
      0.1
    else
      0.01
    end
  end

  before do
    allow(Calabash::Device).to receive(:default).at_least(:once).and_return device
  end

  it '#enter_text' do
    existing_text = 'existing'
    options = { existing_text: existing_text }
    expect(world).to receive(:wait_for_keyboard).and_return true
    expect(world).to receive(:text_from_keyboard_first_responder).and_return existing_text
    expect(device).to receive(:uia_type_string).with('text', options).and_return({})

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

  describe '#wait_for_keyboard' do
    it 'waits for the keyboard' do
      options =
          {
              timeout: 0.5,
              retry_frequency: 0.01,
              exception_class: Calabash::Wait::TimeoutError
          }
      expect(Calabash::Wait).to receive(:default_options).at_least(:once).and_return(options)
      expect(world).to receive(:keyboard_visible?).and_return(false, true)

      expect do
        world.wait_for_keyboard(5)
      end.not_to raise_error
    end

    it 'raises a timeout error if keyboard does not appear' do
      expect(world).to receive(:keyboard_visible?).at_least(:once).and_return false

      expect do
        world.wait_for_keyboard(short_timeout)
      end.to raise_error Calabash::Wait::TimeoutError
    end

    it 'uses default time out if none is given' do
      options =
          {
              timeout: 0.5,
              retry_frequency: 0.01,
              exception_class: Calabash::Wait::TimeoutError
          }
      expect(Calabash::Wait).to receive(:default_options).at_least(:once).and_return(options)
      expect(world).to receive(:keyboard_visible?).and_return(false, true)
      message = 'Timed out after 0.5 seconds waiting for the keyboard to appear'
      expect(world).to receive(:wait_for).with(message, timeout: 0.5).and_call_original

      expect do
        world.wait_for_keyboard
      end.not_to raise_error
    end
  end

  describe '#wait_for_no_keyboard' do
    it 'waits for no visible keyboard' do
      options =
          {
              timeout: 0.5,
              retry_frequency: 0.01,
              exception_class: Calabash::Wait::TimeoutError
          }
      expect(Calabash::Wait).to receive(:default_options).at_least(:once).and_return(options)
      expect(world).to receive(:keyboard_visible?).and_return(true, false)

      expect do
        world.wait_for_no_keyboard(5)
      end.not_to raise_error
    end

    it 'raises a timeout error if keyboard does not disappear' do
      expect(world).to receive(:keyboard_visible?).at_least(:once).and_return true

      expect do
        world.wait_for_no_keyboard(short_timeout)
      end.to raise_error Calabash::Wait::TimeoutError
    end

    it 'uses default time out if none is given' do
      options =
          {
              timeout: 0.5,
              retry_frequency: 0.01,
              exception_class: Calabash::Wait::TimeoutError
          }
      expect(Calabash::Wait).to receive(:default_options).at_least(:once).and_return(options)
      expect(world).to receive(:keyboard_visible?).and_return(true, false)
      message = 'Timed out after 0.5 seconds waiting for the keyboard to disappear'
      expect(world).to receive(:wait_for).with(message, timeout: 0.5).and_call_original

      expect do
        world.wait_for_no_keyboard
      end.not_to raise_error
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

    it 'returns the default Wait timeout otherwise' do
      expect(Calabash::Wait).to receive(:default_options).and_return(timeout: 0.4)

      expect(world.send(:keyboard_wait_timeout, nil)).to be == 0.4
    end
  end

  it '#tap_keyboard_action_key' do
    script = "uia.keyboard().typeString('\\n')"
    expect(device).to receive(:uia_route).with(script).and_return []

    expect(world.tap_keyboard_action_key).to be_truthy
  end

  describe '#tap_keyboard_delete_key' do
    it "taps the element marked 'Delete'" do
      script = "uia.keyboard().elements().firstWithName('Delete').tap()"
      expect(device).to receive(:uia_route).with(script).and_return []

      expect(world.tap_keyboard_delete_key).to be_truthy
    end

    it 'respects the :delete_key_label' do
      label = 'Slet'
      script = "uia.keyboard().elements().firstWithName('Slet').tap()"
      expect(device).to receive(:uia_route).with(script).and_return []

      options = { delete_key_label: label }
      expect(world.tap_keyboard_delete_key(options)).to be_truthy
    end

    describe 'respects :use_escaped_char' do
      it 'uses the default escape sequence' do
        script = "uia.keyboard().typeString('\\b')"
        expect(device).to receive(:uia_route).with(script).and_return []

        options = { use_escaped_char: '\b' }
        expect(world.tap_keyboard_delete_key(options)).to be_truthy
      end

      it 'used the escape sequence the user passes' do
        char = '\d'
        script = "uia.keyboard().typeString('#{char}')"
        expect(device).to receive(:uia_route).with(script).and_return []

        options = { use_escaped_char: char }
        expect(world.tap_keyboard_delete_key(options)).to be_truthy
      end
    end
  end
end
