describe Calabash::Text do
  let(:dummy_class) {Class.new {include Calabash}}
  let(:dummy) {dummy_class.new}

  let(:dummy_device_class) {Class.new(Calabash::Device) {def initialize; end}}
  let(:dummy_device) {dummy_device_class.new}

  describe '#enter_text' do
    it 'should delegate to the default device' do
      args = ['my-text']

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(Calabash::Device.default).to receive(:enter_text).with(*args)

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

  describe '#tap_keyboard_action_key' do
    it 'should invoke the implementation method' do
      expect(dummy).to receive(:_tap_keyboard_action_key)

      dummy.tap_keyboard_action_key
    end
  end

  describe '#_enter_text_in' do
    it 'should have an abstract implementation' do
      args = ['my query', 'my text']

      expect{dummy._enter_text_in(*args)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_tap_keyboard_action_key' do
    it 'should have an abstract implementation' do
      expect{dummy._tap_keyboard_action_key}.to raise_error(Calabash::AbstractMethodError)
    end
  end
end
