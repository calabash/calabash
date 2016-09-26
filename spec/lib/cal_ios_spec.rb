describe "cal_IOS" do
  it 'should have all the Calabash iOS methods in its scope' do
    expect(CalabashIOSMethods).to include(::Calabash::IOSInternal)
  end

  it 'should not have any of the Calabash methods in its scope' do
    expect(CalabashIOSMethods).not_to include(::Calabash)
    expect(CalabashIOSMethods).not_to include(::Calabash)
  end

  it 'should not have any of the Calabash Android methods in its scope' do
    expect(CalabashIOSMethods).not_to include(::Calabash::Android)
    expect(CalabashIOSMethods).not_to include(::Calabash::AndroidInternal)
  end

  it 'should invoke the methods defined in the Calabash::IOS module' do
    methods = Class.new do
      def tap(arg)

      end
    end.new

    expect(CalabashIOSMethods).to receive(:new).and_return(methods)
    expect(methods).to receive(:tap).with(:arg)

    cal_ios.tap(:arg)
  end

  it 'should be able to call Object and Kernel methods in its implementations' do
    module Calabash
      module IOSInternal
        def test_method
          # Lambda is a kernel method
          lambda do
            :result
          end.call
        end
      end
    end

    calabash_ios_file = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'calabash', 'ios.rb')

    begin
      load calabash_ios_file
    rescue Calabash::RequiredBothPlatformsError
    end

    expect(cal_ios.test_method).to eq(:result)
  end

  it 'should not respond to any Object or Kernel methods' do
    expect{cal_ios.class}.to raise_error(::NoMethodError)
  end

  it 'should change the implementations for `cal` as well' do
    module Calabash
      def test_method
        :wrong_result
      end
    end

    module Calabash
      module IOSInternal
        def test_method
          :result
        end
      end
    end

    calabash_ios_file = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'calabash', 'ios.rb')

    begin
      load calabash_ios_file
    rescue Calabash::RequiredBothPlatformsError
    end

    expect(cal.test_method).to eq(:result)
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
      module IOS
        def _test_method
          :result
        end
      end
    end

    Object.send(:remove_const, :CalabashMethodsInternal)

    calabash_file = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'calabash.rb')
    load calabash_file

    expect(cal.test_method).to eq(:wrong_result)

    calabash_ios_file = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'calabash', 'ios.rb')

    begin
      load calabash_ios_file
    rescue Calabash::RequiredBothPlatformsError
    end

    expect(cal.test_method).to eq(:result)
  end
end
