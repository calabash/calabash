require 'calabash/android'

describe Calabash::Android do

  before(:each) do
    allow_any_instance_of(Calabash::Application).to receive(:ensure_application_path)
  end

  let(:dummy) {Class.new {include Calabash::Android}.new}
  let(:dummy_device_class) {Class.new(Calabash::Android::Device) {def initialize; end}}
  let(:dummy_device) {dummy_device_class.new}

  it 'should include Calabash' do
    expect(Calabash::Android.included_modules).to include(Calabash)
  end

  describe '#_calabash_start_app' do
    let(:app_path) {File.expand_path('./app_path')}
    let(:test_app_path) {File.expand_path('./test_app_path')}

    before do
      allow(Calabash::Environment).to receive(:variable).with('APP_PATH').and_return(app_path)
      allow(Calabash::Environment).to receive(:variable).with('TEST_APP_PATH').and_return(test_app_path)
    end

    it 'should invoke calabash_start_app on the default device' do
      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(Calabash::Device.default).to receive(:calabash_start_app)

      dummy.calabash_start_app
    end

    it 'should use environment variables if nothing else is given' do
      application = Calabash::Android::Application.new(app_path, test_app_path)

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      allow(Calabash::Android::Application).to receive(:new).with(app_path, test_app_path).and_return(application)
      expect(dummy_device).to receive(:calabash_start_app).with(application, {})

      dummy.calabash_start_app
    end

    it 'should use app paths and options if given' do
      app_path = File.expand_path('my_app_path')
      test_app_path = File.expand_path('my_test_app_path')
      main_activity = 'my main activity'
      application = Calabash::Android::Application.new(app_path, test_app_path)

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      allow(Calabash::Android::Application).to receive(:new).with(app_path, test_app_path).and_return(application)
      expect(dummy_device).to receive(:calabash_start_app).with(application, hash_including(main_activity: main_activity))

      options =
          {
              application_path: app_path,
              test_server_path: test_app_path,
              main_activity: main_activity
          }
      dummy.calabash_start_app(options)
    end
  end
end
