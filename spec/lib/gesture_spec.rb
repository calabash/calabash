describe Calabash::Gestures do
  let(:dummy) {Class.new {include Calabash}}
  let(:dummy_instance) {dummy.new}
  let(:dummy_device_class) {Class.new(Calabash::Device) {def initialize; end}}
  let(:dummy_device) {dummy_device_class.new}

  describe '#tap' do
    it 'should delegate to the default device' do
      args = ["my query", {my: :option}]
      query = Calabash::Query.new(args[0])
      allow(Calabash::Query).to receive(:new).with(args[0]).and_return(query)
      expected = [Calabash::Query.new("my query"), {my: :option}]

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(Calabash::Device.default).to receive(:tap).with(*expected)

      dummy_instance.tap(*args)
    end

    it 'raises an error if query is not passed' do
      expect do
        dummy_instance.tap(nil, {option: 'my opt'})
      end.to raise_error ArgumentError

      expect do
        dummy_instance.tap(:not_a_query, {option: 'my opt'})
      end.to raise_error ArgumentError
    end
  end

  describe '#double_tap' do
    it 'should delegate to the default device' do
      args = ["my query", {my: :option}]
      query = Calabash::Query.new(args[0])
      allow(Calabash::Query).to receive(:new).with(args[0]).and_return(query)
      expected = [Calabash::Query.new("my query"), {my: :option}]

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(Calabash::Device.default).to receive(:double_tap).with(*expected)

      dummy_instance.double_tap(*args)
    end

    it 'raises an error if query is not passed' do
      expect do
        dummy_instance.double_tap(nil, {option: 'my opt'})
      end.to raise_error ArgumentError

      expect do
        dummy_instance.double_tap(:not_a_query, {option: 'my opt'})
      end.to raise_error ArgumentError
    end
  end

  describe '#long_press' do
    it 'should delegate to the default device' do
      args = ["my query", {my: :option}]
      query = Calabash::Query.new(args[0])
      allow(Calabash::Query).to receive(:new).with(args[0]).and_return(query)
      expected = [Calabash::Query.new("my query"), {my: :option}]

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(Calabash::Device.default).to receive(:long_press).with(*expected)

      dummy_instance.long_press(*args)
    end

    it 'raises an error if query is not passed' do
      expect do
        dummy_instance.long_press(nil, {option: 'my opt'})
      end.to raise_error ArgumentError

      expect do
        dummy_instance.long_press(:not_a_query, {option: 'my opt'})
      end.to raise_error ArgumentError
    end
  end

  describe '#pan' do
    it 'should delegate to the default device' do
      query = "my query"
      from = {x: 0, y: 0}
      to = {x: 0, y: 0}
      options = {my: :arg}
      args = [query, from, to, options]

      q = Calabash::Query.new(query)
      allow(Calabash::Query).to receive(:new).with(query).and_return(q)
      expected = [Calabash::Query.new(query), from, to, options]

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(Calabash::Device.default).to receive(:pan).with(*expected)

      dummy_instance.pan(*args)
    end

    it 'raises an error if query is not passed' do
      from = {x: 0, y: 0}
      to = {x: 0, y: 0}
      options = {my: :arg}

      expect do
        dummy_instance.pan(nil, from, to, options)
      end.to raise_error ArgumentError

      expect do
        dummy_instance.pan(:not_a_query, from, to, options)
      end.to raise_error ArgumentError
    end
  end

  describe '#pan_between' do
    it 'should delegate to the default device' do
      query_from = "my query"
      query_to = "my query 2"
      options = {my: :arg}
      args = [query_from, query_to, options]

      from = Calabash::Query.new(query_from)
      to = Calabash::Query.new(query_to)

      allow(Calabash::Query).to receive(:new).with(query_from).and_return(from)
      allow(Calabash::Query).to receive(:new).with(query_to).and_return(to)

      expected = [from, to, options]

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(Calabash::Device.default).to receive(:pan_between).with(*expected)

      dummy_instance.pan_between(*args)
    end

    it 'raises an error if invalid query_from' do
      query_from = "my query"
      query_to = "my query 2"

      allow(Calabash::Query).to receive(:valid_query?).with(query_from).and_return(false)

      expect do
        dummy_instance.pan_between(query_from, query_to)
      end.to raise_error ArgumentError
    end

    it 'raises an error if invalid query_to' do
      query_from = "my query"
      query_to = "my query 2"

      allow(Calabash::Query).to receive(:valid_query?).with(query_from).and_return(true)
      allow(Calabash::Query).to receive(:valid_query?).with(query_to).and_return(false)

      expect do
        dummy_instance.pan_between(query_from, query_to)
      end.to raise_error ArgumentError
    end
  end

  describe '#pan_left' do
    it 'should invoke #pan with the right coordinates' do
      query = "my query"
      from = {x: 95, y: 50}
      to = {x: 5, y: 50}
      options = {my: :arg}

      expect(dummy_instance).to receive(:pan).with(query, from, to, options)
      dummy_instance.pan_left(query, options)
    end
  end

  describe '#pan_right' do
    it 'should invoke #pan with the right coordinates' do
      query = "my query"
      from = {x: 5, y: 50}
      to = {x: 95, y: 50}
      options = {my: :arg}

      expect(dummy_instance).to receive(:pan).with(query, from, to, options)
      dummy_instance.pan_right(query, options)
    end
  end

  describe '#pan_up' do
    it 'should invoke #pan with the right coordinates' do
      query = "my query"
      from = {x: 50, y: 95}
      to = {x: 50, y: 5}
      options = {my: :arg}

      expect(dummy_instance).to receive(:pan).with(query, from, to, options)
      dummy_instance.pan_up(query, options)
    end
  end

  describe '#pan_down' do
    it 'should invoke #pan with the right coordinates' do
      query = "my query"
      from = {x: 50, y: 5}
      to = {x: 50, y: 95}
      options = {my: :arg}

      expect(dummy_instance).to receive(:pan).with(query, from, to, options)
      dummy_instance.pan_down(query, options)
    end
  end

  describe '#pan_screen_left' do
    it 'should invoke #pan_left' do
      options = {my: :arg}

      expect(dummy_instance).to receive(:pan_left).with("*", options)
      dummy_instance.pan_screen_left(options)
    end
  end

  describe '#pan_screen_right' do
    it 'should invoke #pan_right' do
      options = {my: :arg}

      expect(dummy_instance).to receive(:pan_right).with("*", options)
      dummy_instance.pan_screen_right(options)
    end
  end

  describe '#pan_screen_up' do
    it 'should invoke #_pan_screen_up' do
      options = {my: :arg}

      expect(dummy_instance).to receive(:_pan_screen_up).with(options)
      dummy_instance.pan_screen_up(options)
    end
  end

  describe '#pan_screen_down' do
    it 'should invoke #_pan_screen_down' do
      options = {my: :arg}

      expect(dummy_instance).to receive(:_pan_screen_down).with(options)
      dummy_instance.pan_screen_down(options)
    end
  end

  describe '#flick' do
    it 'should delegate to the default device' do
      query = "my query"
      from = {x: 0, y: 0}
      to = {x: 0, y: 0}
      options = {my: :arg}
      args = [query, from, to, options]

      q = Calabash::Query.new(query)
      allow(Calabash::Query).to receive(:new).with(query).and_return(q)
      expected = [Calabash::Query.new(query), from, to, options]

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(Calabash::Device.default).to receive(:flick).with(*expected)

      dummy_instance.flick(*args)
    end

    it 'raises an error if query is not passed' do
      from = {x: 0, y: 0}
      to = {x: 0, y: 0}
      options = {my: :arg}

      expect do
        dummy_instance.flick(nil, from, to, options)
      end.to raise_error ArgumentError

      expect do
        dummy_instance.flick(:not_a_query, from, to, options)
      end.to raise_error ArgumentError
    end
  end

  describe '#flick_left' do
    it 'should invoke #flick with the right coordinates' do
      query = "my query"
      from = {x: 90, y: 50}
      to = {x: 10, y: 50}
      options = {my: :arg}

      expect(dummy_instance).to receive(:flick).with(query, from, to, options)
      dummy_instance.flick_left(query, options)
    end
  end

  describe '#flick_right' do
    it 'should invoke #flick with the right coordinates' do
      query = "my query"
      from = {x: 10, y: 50}
      to = {x: 90, y: 50}
      options = {my: :arg}

      expect(dummy_instance).to receive(:flick).with(query, from, to, options)
      dummy_instance.flick_right(query, options)
    end
  end

  describe '#flick_up' do
    it 'should invoke #flick with the right coordinates' do
      query = "my query"
      from = {x: 50, y: 90}
      to = {x: 50, y: 10}
      options = {my: :arg}

      expect(dummy_instance).to receive(:flick).with(query, from, to, options)
      dummy_instance.flick_up(query, options)
    end
  end

  describe '#flick_down' do
    it 'should invoke #flick with the right coordinates' do
      query = "my query"
      from = {x: 50, y: 10}
      to = {x: 50, y: 90}
      options = {my: :arg}

      expect(dummy_instance).to receive(:flick).with(query, from, to, options)
      dummy_instance.flick_down(query, options)
    end
  end

  describe '#flick_screen_left' do
    it 'should invoke #flick_left' do
      options = {my: :arg}

      expect(dummy_instance).to receive(:flick_left).with("*", options)
      dummy_instance.flick_screen_left(options)
    end
  end

  describe '#flick_screen_right' do
    it 'should invoke #flick_right' do
      options = {my: :arg}

      expect(dummy_instance).to receive(:flick_right).with("*", options)
      dummy_instance.flick_screen_right(options)
    end
  end

  describe '#flick_screen_up' do
    it 'should invoke #_flick_screen_up' do
      options = {my: :arg}

      expect(dummy_instance).to receive(:_flick_screen_up).with(options)
      dummy_instance.flick_screen_up(options)
    end
  end

  describe '#flick_screen_down' do
    it 'should invoke #_flick_screen_down' do
      options = {my: :arg}

      expect(dummy_instance).to receive(:_flick_screen_down).with(options)
      dummy_instance.flick_screen_down(options)
    end
  end

  describe '#_pan_screen_up' do
    it 'should have an abstract implementation' do
      expect{dummy_instance.send(:_pan_screen_up)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_pan_screen_down' do
    it 'should have an abstract implementation' do
      expect{dummy_instance.send(:_pan_screen_down)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_flick_screen_up' do
    it 'should have an abstract implementation' do
      expect{dummy_instance.send(:_flick_screen_up)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_flick_screen_down' do
    it 'should have an abstract implementation' do
      expect{dummy_instance.send(:_flick_screen_down)}.to raise_error(Calabash::AbstractMethodError)
    end
  end
end
