describe Calabash::IOS::API do

  let(:device) do
    Class.new do
      def uia_type_string(_, _); ; end
    end.new
  end

  let(:world) do
    Class.new do
      require 'calabash/ios/api'
      require 'calabash/gestures'
      include Calabash::IOS::API

      include Calabash::Gestures

      def to_s; '#<Cucumber World>'; end
      def inspect; to_s; end
    end.new
  end

  before do
    allow(Calabash::IOS::Device).to receive(:default).at_least(:once).and_return device
  end

  it '#enter_text' do
    existing_text = 'existing'
    options = { existing_text: existing_text }
    expect(world).to receive(:wait_for_keyboard).and_return true
    expect(world).to receive(:text_from_keyboard_first_responder).and_return existing_text
    expect(device).to receive(:uia_type_string).with('text', options).and_return({})

    expect(world.enter_text('text')).to be_truthy
  end

  it '#enter_text_in' do
    expect(world).to receive(:tap).with('query').and_return([])
    expect(world).to receive(:enter_text).with('text').and_return({})

    expect(world._enter_text_in('query', 'text')).to be_truthy
  end
end
