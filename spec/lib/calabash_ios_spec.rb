require 'calabash/ios'

describe Calabash::IOS do
  before(:each) do
    allow_any_instance_of(Calabash::Application).to receive(:ensure_application_path)
  end

  it 'should include Calabash' do
    expect(Calabash::IOS.included_modules).to include(Calabash)
  end

  let(:dummy) {Class.new {include Calabash::IOS}.new}
  let(:dummy_device_class) {Class.new(Calabash::IOS::Device) {def initialize; end}}
  let(:dummy_device) {dummy_device_class.new}

  describe '#_calabash_start_app' do
    let(:app_path) {File.expand_path('./app_path')}
    let(:app_identifier) {'identifier'}

    before do
      stub_const('Calabash::Environment::APP_PATH', app_path)
      allow(Calabash::Environment).to receive(:variable).with('BUNDLE_ID').and_return(app_identifier)
    end

    it 'should invoke calabash_start_app on the default device' do
      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(Calabash::Device.default).to receive(:calabash_start_app)

      dummy.calabash_start_app
    end

    it 'should use environment variables if nothing else is given' do
      application = Calabash::IOS::Application.new(app_path, identifier: app_identifier)
      options = {my: :args}

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      allow(Calabash::IOS::Application).to receive(:new).with(app_path, {identifier: app_identifier}).and_return(application)
      expect(dummy_device).to receive(:calabash_start_app).with(application, options)

      dummy.calabash_start_app(options)
    end

    it 'should use app paths and options if given' do
      app_path = File.expand_path('my_app_path')
      app_identifier = 'my-identifier'
      application = Calabash::IOS::Application.new(app_path, identifier: app_identifier)
      options = {my: :args}

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      allow(Calabash::IOS::Application).to receive(:new).with(app_path, {identifier: app_identifier}).and_return(application)
      expect(dummy_device).to receive(:calabash_start_app).with(application, options)

      app_options =
          {
              application_path: app_path,
              application_identifier: app_identifier
          }

      dummy.calabash_start_app(options.merge(app_options))
    end
  end
end