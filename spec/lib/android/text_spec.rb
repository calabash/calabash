describe Calabash::Android::Text do
  let(:dummy_class) {Class.new {include Calabash::Android}}
  let(:world) {dummy_class.new}

  let(:dummy_device_class) {Class.new(Calabash::Device) {def initialize; end}}
  let(:dummy_device) {dummy_device_class.new}

  before do
    allow(Calabash::Device).to receive(:default).and_return(dummy_device)
  end

  describe '#_keyboard_visible?' do
    it 'should ask the default device if the keyboard is visible' do
      expect(dummy_device).to receive(:keyboard_visible?).and_return("result")

      expect(world._keyboard_visible?).to eq("result")
    end
  end
end