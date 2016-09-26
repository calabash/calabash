describe "cal_android" do
  it 'should have all the Calabash Android methods in its scope' do
    expect(CalabashAndroidMethods).to include(::Calabash::AndroidInternal)
  end

  it 'should not have any of the Calabash methods in its scope' do
    expect(CalabashAndroidMethods).not_to include(::Calabash)
    expect(CalabashAndroidMethods).not_to include(::Calabash)
  end

  it 'should not have any of the Calabash iOS methods in its scope' do
    expect(CalabashAndroidMethods).not_to include(::Calabash::IOS)
    expect(CalabashAndroidMethods).not_to include(::Calabash::IOSInternal)
  end

  it 'should invoke the methods defined in the Calabash::Android module' do
    methods = Class.new do
      def tap(arg)

      end
    end.new

    expect(CalabashAndroidMethods).to receive(:new).and_return(methods)
    expect(methods).to receive(:tap).with(:arg)

    cal_android.tap(:arg)
  end

  it 'should be able to call Object and Kernel methods in its implementations' do
    module Calabash
      module AndroidInternal
        def test_method
          # Lambda is a kernel method
          lambda do
            :result
          end.call
        end
      end
    end

    calabash_android_file = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'calabash', 'android.rb')

    begin
      load calabash_android_file
    rescue Calabash::RequiredBothPlatformsError
    end

    expect(cal_android.test_method).to eq(:result)
  end

  it 'should not respond to any Object or Kernel methods' do
    expect{cal_android.class}.to raise_error(::NoMethodError)
  end

  it 'should change the implementations for `cal` as well' do
    module Calabash
      def test_method
        _test_method
      end

      def _test_method
        :wrong_result
      end
    end

    module Calabash
      module Android
        def _test_method
          :result
        end
      end
    end

    Object.send(:remove_const, :CalabashMethodsInternal)

    calabash_file = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'calabash.rb')
    load calabash_file

    expect(cal.test_method).to eq(:wrong_result)

    calabash_android_file = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'calabash', 'android.rb')

    begin
      load calabash_android_file
    rescue Calabash::RequiredBothPlatformsError
    end

    expect(cal.test_method).to eq(:result)
  end
end
