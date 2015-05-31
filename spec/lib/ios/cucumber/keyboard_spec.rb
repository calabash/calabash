describe Calabash::IOS::Cucumber do

  let(:device) do
    Class.new do
      def status_bar_orientation; ; end
    end.new
  end

  let(:world) do
    Class.new do
      require 'calabash/ios/cucumber'
      include Calabash::IOS::Cucumber
      def to_s
        '#<Cucumber World>'
      end

      def inspect
        to_s
      end
    end.new
  end

  describe '#docked_keyboard_visible?' do

  end

  describe '#undocked_keyboard_visible?' do

  end

  describe '#split_keyboard_visible?' do

  end

  describe '#keyboard_visible?' do

  end

  describe '#wait_for_keyboard' do

  end

  describe '#text_of_first_responder' do

  end
end
