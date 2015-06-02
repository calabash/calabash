describe Calabash::Android::Gestures do
  let(:dummy_class) {Class.new {include Calabash::Android}}
  let(:dummy) {dummy_class.new}

  let(:dummy_device_class) {Class.new(Calabash::Device) {def initialize; end}}
  let(:dummy_device) {dummy_device_class.new}

  before do
    allow(Calabash::Device).to receive(:default).and_return(dummy_device)
  end

  describe '#_pan_screen_up' do
    it 'should pan the screen up' do
      options = {my: :option}
      args = ["* id:'content'", {x: 50, y: 90}, {x: 50, y: 10}, options]

      expect(Calabash::Device.default).to receive(:pan).with(*args)

      dummy.send(:_pan_screen_up, options)
    end
  end

  describe '#_pan_screen_down' do
    it 'should pan the screen down' do
      options = {my: :option}
      args = ["* id:'content'", {x: 50, y: 10}, {x: 50, y: 90}, options]

      expect(Calabash::Device.default).to receive(:pan).with(*args)

      dummy.send(:_pan_screen_down, options)
    end
  end

  describe '#_flick_screen_up' do
    it 'should flick the screen up' do
      options = {my: :option}
      args = ["* id:'content'", {x: 50, y: 90}, {x: 50, y: 10}, options]

      expect(Calabash::Device.default).to receive(:flick).with(*args)

      dummy.send(:_flick_screen_up, options)
    end
  end

  describe '#_flick_screen_down' do
    it 'should flick the screen down' do
      options = {my: :option}
      args = ["* id:'content'", {x: 50, y: 10}, {x: 50, y: 90}, options]

      expect(Calabash::Device.default).to receive(:flick).with(*args)

      dummy.send(:_flick_screen_down, options)
    end
  end
end
