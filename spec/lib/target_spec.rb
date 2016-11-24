describe Calabash::Target do
  it 'takes a device as its constructor' do
    Calabash::Target.new(Calabash::Device.allocate)
  end

  it 'delegates all valid method calls to the device given in its constructor' do
    fake_device = Class.new do
      def foo
        'returned-foo'
      end

      def bar
        foo + '-from-bar'
      end

      def block(&block)
        block.call
      end
    end.new

    target = Calabash::Target.new(fake_device)

    expect(target.foo).to eq('returned-foo')
    expect(target.bar).to eq('returned-foo-from-bar')
    expect(target.block{'b'}).to eq('b')
  end

  it 'raises a NoMethodError if the device does not respond to the given method' do
    target = Calabash::Target.new(Object.new)

    expect{target.non_existing_method}.to raise_error(NoMethodError)
  end
end