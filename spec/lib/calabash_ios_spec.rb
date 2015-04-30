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
    let(:app) {:my_app}

    it 'should invoke calabash_start_app on the default device' do
      options = {my: :arg}
      dup_options = {my2: :arg2}

      allow(Calabash::Device).to receive(:default).and_return(dummy_device)
      expect(options).to receive(:dup).and_return(dup_options)
      expect(Calabash::Device.default).to receive(:calabash_start_app).with(app, dup_options)

      dummy._calabash_start_app(app, options)
    end
  end
end