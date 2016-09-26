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

  it 'cannot be loaded alongside Calabash iOS' do
    # Calabash::IOSInternal is defined
    calabash_android_file = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'calabash', 'android.rb')

    expect{load calabash_android_file}.to raise_error(Calabash::RequiredBothPlatformsError)
  end
end
