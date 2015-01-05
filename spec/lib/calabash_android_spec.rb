require 'calabash/android'

describe Calabash::Android do
  let(:dummy) {Class.new {include Calabash::Android}.new}

  let(:dummy_device_class) {Class.new(Calabash::Android::Device) {def initialize; end}}
  let(:dummy_device) {dummy_device_class.new}

  it 'should include Calabash' do
    expect(Calabash::Android.included_modules).to include(Calabash)
  end

  describe '#_start_test_server' do
    before do
      allow(Calabash::Environment).to receive(:variable).with('APP_PATH').and_return('app_path')
      allow(Calabash::Environment).to receive(:variable).with('MAIN_ACTIVITY').and_return('main_activity')
      allow(Calabash::Environment).to receive(:variable).with('TEST_APP_PATH').and_return('test_app_path')
    end

    it 'should invoke start_test_server on the default device' do
      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(Calabash::Device.default).to receive(:start_test_server)

      dummy.start_test_server
    end

    it 'should use environment variables if nothing else is given' do
      dummy_device2 = Class.new {}.new

      dummy_device2.define_singleton_method(:start_test_server) do |application, test_server, options|
        application.instance_eval do
          raise "invalid application ('#{@application_path}' != 'app_path')" unless @application_path == 'app_path'
        end

        test_server.instance_eval do
          raise "invalid test_server ('#{@application_path}' != 'test_app_path')" unless @application_path == 'test_app_path'
        end

        raise 'invalid options' unless options[:main_activity] == 'main_activity'
      end

      allow(Calabash::Device).to receive(:default).and_return(dummy_device2)

      dummy.start_test_server
    end

    it 'should use app paths and options if given' do
      dummy_device2 = Class.new {}.new

      dummy_device2.define_singleton_method(:start_test_server) do |application, test_server, options|
        application.instance_eval do
          raise "invalid application ('#{@application_path}' != 'my_app_path')" unless @application_path == 'my_app_path'
        end

        test_server.instance_eval do
          raise "invalid test_server ('#{@application_path}' != 'my_test_app_path')" unless @application_path == 'my_test_app_path'
        end

        raise 'invalid options' unless options[:main_activity] == 'my_main_activity'
      end

      allow(Calabash::Device).to receive(:default).and_return(dummy_device2)

      dummy.start_test_server(application_path: 'my_app_path', test_server_path: 'my_test_app_path', main_activity: 'my_main_activity')
    end
  end
end
