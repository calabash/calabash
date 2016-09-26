describe "cal" do
  it 'should have all the Calabash methods in its scope' do
    expect(CalabashMethods).to include(::Calabash)
  end

  it 'should not have any of the Calabash Android methods in its scope' do
    expect(CalabashMethods).not_to include(::Calabash::Android)
    expect(CalabashMethods).not_to include(::Calabash::AndroidInternal)
  end

  it 'should not have any of the Calabash iOS methods in its scope' do
    expect(CalabashMethods).not_to include(::Calabash::IOS)
    expect(CalabashMethods).not_to include(::Calabash::IOSInternal)
  end

  it 'should invoke the methods defined in the Calabash module' do
    methods = Class.new do
      def tap(arg)

      end
    end.new

    expect(CalabashMethods).to receive(:new).and_return(methods)
    expect(methods).to receive(:tap).with(:arg)

    cal.tap(:arg)
  end

  it 'should be able to call Object and Kernel methods in its implementations' do
    module Calabash
      def test_method
        # Lambda is a kernel method
        lambda do
          :result
        end.call
      end
    end

    calabash_file = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'calabash.rb')
    load calabash_file

    expect(cal.test_method).to eq(:result)
  end

  it 'should not respond to any Object or Kernel methods' do
    expect{cal.class}.to raise_error(::NoMethodError)
  end
end