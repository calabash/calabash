describe Calabash::IOS::Device do
  it 'should inherit from Calabash::Device' do
    expect(Calabash::IOS::Device.new).to be_a(Calabash::Device)
  end

  it 'should be able to create a new instance from a serial' do
    serial = '123456789abcde'
    device = Calabash::IOS::Device.from_serial(serial)

    expect(device).to be_a(Calabash::IOS::Device)
    expect(device.serial).to eq(serial)
  end
end