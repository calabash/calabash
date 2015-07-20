describe Calabash::IOS::UIAutomation do

  let(:device) do
    Class.new do
    end.new
  end

  let(:world) do
    Class.new do
      require 'calabash/ios/api/uiautomation'
      include Calabash::IOS::UIAutomation
      def to_s; '#<Cucumber World>'; end
      def inspect; to_s; end
    end.new
  end

  describe '#evaluate_uia' do

  end
end
