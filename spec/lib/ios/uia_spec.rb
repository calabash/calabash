describe Calabash::IOS::UIA do

  let(:device) do
    Class.new do
      def evaluate_uia(_) ; end
    end.new
  end

  let(:world) do
    Class.new do
      include Calabash::IOS
      def to_s; '#<Cucumber World>'; end
      def inspect; to_s; end
    end.new
  end

  let(:script) { 'javascript' }

  it '#uia' do
    expect(Calabash::IOS::Device).to receive(:default).and_return device
    expect(device).to receive(:evaluate_uia).with(script).and_return :result

    expect(world.uia(script)).to be == :result
  end

  it '#uia_with_target' do
    expected = "UIATarget.localTarget().#{script}"
    expect(Calabash::IOS::Device).to receive(:default).and_return device
    expect(device).to receive(:evaluate_uia).with(expected).and_return :result

    expect(world.uia_with_target(script)).to be == :result
  end

  it '#uia_with_app' do
    expected = "UIATarget.localTarget().frontMostApp().#{script}"
    expect(Calabash::IOS::Device).to receive(:default).and_return device
    expect(device).to receive(:evaluate_uia).with(expected).and_return :result

    expect(world.uia_with_app(script)).to be == :result
  end

  it '#uia_with_main_window' do
    expected = "UIATarget.localTarget().frontMostApp().mainWindow().#{script}"
    expect(Calabash::IOS::Device).to receive(:default).and_return device
    expect(device).to receive(:evaluate_uia).with(expected).and_return :result

    expect(world.uia_with_main_window(script)).to be == :result
  end
end
