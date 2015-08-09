describe Calabash::IOS::UIAMixin do

  let(:device) do
    Class.new do
      include Calabash::IOS::UIAMixin
      include Calabash::IOS::Routes::UIARouteMixin
    end.new
  end

  it '#evaluate_uia' do
    script = 'javascript'
    expect(device).to receive(:uia_route).with(script).and_return :result

    expect(device.evaluate_uia(script)).to be == :result
  end
end
