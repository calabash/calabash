describe Calabash::Android::Gestures do
  let(:dummy_class) {Class.new {include Calabash::Android}}
  let(:dummy) {dummy_class.new}

  let(:dummy_device_class) {Class.new(Calabash::Device) {def initialize; end}}
  let(:dummy_device) {dummy_device_class.new}

  let(:device) do
    Class.new(Calabash::Device) do
      def initialize; end
    end.new
  end

  let(:target) do
    Class.new(Calabash::Target) do
    end.new(device, nil)
  end

  before do
    $_target = target

    clz = Class.new do
      def obtain_default_target
        $_target
      end
    end

    allow(Calabash::Internal).to receive(:default_target_state).and_return(clz.new)
  end

  describe '#_pan_screen_up' do
    it 'should pan the screen up' do
      args = ["* id:'content'", {x: 50, y: 90}, {x: 50, y: 10}]
      query = Calabash::Query.new(args[0])
      allow(Calabash::Query).to receive(:new).with(args[0]).and_return(query)
      expected = [Calabash::Query.new(args[0]), {x: 50, y: 90}, {x: 50, y: 10}, anything]

      expect(target).to receive(:pan).with(*expected)

      dummy.send(:_pan_screen_up)
    end
  end

  describe '#_pan_screen_down' do
    it 'should pan the screen down' do
      args = ["* id:'content'", {x: 50, y: 10}, {x: 50, y: 90}]
      query = Calabash::Query.new(args[0])
      allow(Calabash::Query).to receive(:new).with(args[0]).and_return(query)
      expected = [Calabash::Query.new(args[0]), {x: 50, y: 10}, {x: 50, y: 90}, anything]

      expect(target).to receive(:pan).with(*expected)

      dummy.send(:_pan_screen_down)
    end
  end

  describe '#_flick_screen_up' do
    it 'should flick the screen up' do
      args = ["* id:'content'", {x: 50, y: 90}, {x: 50, y: 10}]
      query = Calabash::Query.new(args[0])
      allow(Calabash::Query).to receive(:new).with(args[0]).and_return(query)
      expected = [Calabash::Query.new(args[0]), {x: 50, y: 90}, {x: 50, y: 10}, anything]

      expect(target).to receive(:flick).with(*expected)

      dummy.send(:_flick_screen_up)
    end
  end

  describe '#_flick_screen_down' do
    it 'should flick the screen down' do
      args = ["* id:'content'", {x: 50, y: 10}, {x: 50, y: 90}]
      query = Calabash::Query.new(args[0])
      allow(Calabash::Query).to receive(:new).with(args[0]).and_return(query)
      expected = [Calabash::Query.new(args[0]), {x: 50, y: 10}, {x: 50, y: 90}, anything]

      expect(target).to receive(:flick).with(*expected)

      dummy.send(:_flick_screen_down)
    end
  end
end
