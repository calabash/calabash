describe Calabash::Text do
  let(:dummy) {Class.new {include Calabash::Text}}

  let(:dummy_device_class) {Class.new(Calabash::Device) {def initialize; end}}
  let(:dummy_device) {dummy_device_class.new}

  describe '#enter_text' do
    it 'should delegate to the default device' do
      args = ['my-text']

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(Calabash::Device.default).to receive(:enter_text).with(*args)

      dummy.new.enter_text(*args)
    end
  end
end
