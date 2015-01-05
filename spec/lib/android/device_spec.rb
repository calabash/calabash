describe Calabash::Android::Device do
  it 'should inherit from Calabash::Device' do
    expect(Calabash::Android::Device.ancestors).to include(Calabash::Device)
  end
end