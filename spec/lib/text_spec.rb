describe Calabash::Text do
  let(:dummy_class) {Class.new {include Calabash; def screenshot_embed; ; end}}
  let(:world) {dummy_class.new}

  let(:dummy_device) do
    Class.new do
      def screenshot(_); end
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
    allow(Calabash::Device).to receive(:default).and_return dummy_device
  end

  describe '#enter_text' do
    it 'should invoke the implementation method' do
      args = ['my-text']

      expect(world).to receive(:_enter_text).with(*args)

      world.enter_text(*args)
    end
  end

  describe '#enter_text_in' do
    it 'should invoke the implementation method' do
      args = ['my query', 'my text']

      expect(world).to receive(:_enter_text_in).with(*args)

      world.enter_text_in(*args)
    end
  end

  describe '#tap_keyboard_action_key' do
    it 'should invoke the implementation method' do
      expect(world).to receive(:_tap_keyboard_action_key)

      world.tap_keyboard_action_key
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
        world.wait_for_keyboard(timeout: 5)
      end.not_to raise_error
    end

    it 'raises a timeout error if keyboard does not appear' do
      expect(world).to receive(:keyboard_visible?).at_least(:once).and_return false

      expect do
        world.wait_for_keyboard(timeout: short_timeout)
      end.to raise_error Calabash::Wait::TimeoutError
    end

    it 'uses default time out if none is given' do
      options =
          {
              retry_frequency: 0.01,
              exception_class: Calabash::Wait::TimeoutError
          }

      time = 22
      stub_const('Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT', time)
      expect(Calabash::Wait).to receive(:default_options).at_least(:once).and_return(options)
      expect(world).to receive(:keyboard_visible?).and_return(false, true)
      message = "Timed out after #{time} seconds waiting for the keyboard to appear"
      expect(world).to receive(:wait_for).with(message, timeout: time).and_call_original

      expect do
        world.wait_for_keyboard
      end.not_to raise_error
    end
  end

  describe '#wait_for_no_keyboard' do
    it 'waits for no visible keyboard' do
      options =
          {
              retry_frequency: 0.01,
              exception_class: Calabash::Wait::TimeoutError
          }
      expect(Calabash::Wait).to receive(:default_options).at_least(:once).and_return(options)
      expect(world).to receive(:keyboard_visible?).and_return(true, false)

      expect do
        world.wait_for_no_keyboard(timeout: 5)
      end.not_to raise_error
    end

    it 'raises a timeout error if keyboard does not disappear' do
      expect(world).to receive(:keyboard_visible?).at_least(:once).and_return true

      expect do
        world.wait_for_no_keyboard(timeout: short_timeout)
      end.to raise_error Calabash::Wait::TimeoutError
    end

    it 'uses default time out if none is given' do
      options =
          {
              retry_frequency: 0.01,
              exception_class: Calabash::Wait::TimeoutError
          }

      time = 22

      expect(Calabash::Wait).to receive(:default_options).at_least(:once).and_return(options)
      stub_const('Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT', time)
      expect(world).to receive(:keyboard_visible?).and_return(true, false)
      message = "Timed out after #{time} seconds waiting for the keyboard to disappear"
      expect(world).to receive(:wait_for).with(message, timeout: time).and_call_original

      expect do
        world.wait_for_no_keyboard
      end.not_to raise_error
    end
  end

  describe '#escape_single_quotes' do
    it 'calls self.escape_single_quotes' do
      arg = 'my string'
      expected = :expected

      expect(Calabash::Text).to receive(:escape_single_quotes).with(arg).and_return(expected)

      expect(world.escape_single_quotes(arg)).to eq(expected)
    end
  end

  describe '#self.escape_single_quotes' do
    it 'does nothing if there are no single quotes to escape' do
      string = 'I have no quotes.'
      expect(Calabash::Text.escape_single_quotes(string)).to be == string
    end

    it 'escapes all single quotes' do
      string = "Let's get this done y'all."
      expected = "Let\\'s get this done y\\'all."
      expect(Calabash::Text.escape_single_quotes(string)).to be == expected
    end
  end

  describe '#_enter_text_in' do
    it 'should have an abstract implementation' do
      args = ['my query', 'my text']

      expect{world._enter_text_in(*args)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_tap_keyboard_action_key' do
    it 'should have an abstract implementation' do
      expect{world._tap_keyboard_action_key(nil)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_keyboard_visible?' do
    it 'should have an abstract implementation' do
      expect{world._keyboard_visible?}.to raise_error(Calabash::AbstractMethodError)
    end
  end
end
