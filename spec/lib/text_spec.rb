describe Calabash::Text do
  let(:dummy_class) {Class.new {include Calabash}}
  let(:dummy) {dummy_class.new}

  let(:dummy_device_class) {Class.new(Calabash::Device) {def initialize; end}}
  let(:dummy_device) {dummy_device_class.new}

  describe '#enter_text' do
    it 'should invoke the implementation method' do
      args = ['my-text']

      expect(dummy).to receive(:_enter_text).with(*args)

      dummy.enter_text(*args)
    end
  end

  describe '#enter_text_in' do
    it 'should invoke the implementation method' do
      args = ['my query', 'my text']

      expect(dummy).to receive(:_enter_text_in).with(*args)

      dummy.enter_text_in(*args)
    end
  end

  describe '#tap_current_keyboard_action_key' do
    it 'should invoke the implementation method' do
      expect(dummy).to receive(:_tap_current_keyboard_action_key)

      dummy.tap_current_keyboard_action_key
    end
  end

  describe '#escape_single_quotes' do
    it 'calls self.escape_single_quotes' do
      arg = 'my string'
      expected = :expected

      expect(Calabash::Text).to receive(:escape_single_quotes).with(arg).and_return(expected)

      expect(dummy.escape_single_quotes(arg)).to eq(expected)
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

      expect{dummy._enter_text_in(*args)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_tap_current_keyboard_action_key' do
    it 'should have an abstract implementation' do
      expect{dummy._tap_current_keyboard_action_key}.to raise_error(Calabash::AbstractMethodError)
    end
  end
end
