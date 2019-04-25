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

  it 'cannot be loaded alongside Calabash Android' do
    # Calabash::AndroidInternal is defined
    calabash_ios_file = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'calabash', 'ios.rb')

    expect{load calabash_ios_file}.to raise_error(Calabash::RequiredBothPlatformsError)
  end
end
