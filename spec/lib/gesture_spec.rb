describe Calabash::Gestures do
  let(:dummy) {Class.new {include Calabash}}
  let(:dummy_instance) {dummy.new}

  describe '#tap' do
    it 'should invoke the implementation method' do
      query = "my query"
      options = {my: :arg}

      expect(dummy_instance).to receive(:_tap).with(query, options)

      dummy_instance.tap(query, options)
    end
  end

  describe '#double_tap' do
    it 'should invoke the implementation method' do
      query = "my query"
      options = {my: :arg}

      expect(dummy_instance).to receive(:_double_tap).with(query, options)

      dummy_instance.double_tap(query, options)
    end
  end

  describe '#long_press' do
    it 'should invoke the implementation method' do
      query = "my query"
      options = {my: :arg}

      expect(dummy_instance).to receive(:_long_press).with(query, options)

      dummy_instance.long_press(query, options)
    end
  end

  describe '#_tap' do
    it 'should have an abstract implementation' do
      expect{dummy_instance._tap('my query')}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_double_tap' do
    it 'should have an abstract implementation' do
      expect{dummy_instance._double_tap('my query')}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_long_press' do
    it 'should have an abstract implementation' do
      expect{dummy_instance._long_press('my query')}.to raise_error(Calabash::AbstractMethodError)
    end
  end
end
