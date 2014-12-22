describe Calabash::Device do
  describe '#install' do
    it 'should have an abstract implementation' do
      expect{Calabash::Device.new.install({})}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#uninstall' do
    it 'should have an abstract implementation' do
      expect{Calabash::Device.new.uninstall({})}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#default' do
    after do
      Calabash::Device.default = nil
    end

    it 'should be able to set its default device' do
      Calabash::Device.default = :my_device
    end

    it 'should be able to get its default device' do
      device = :my_device

      Calabash::Device.default = device

      expect(Calabash::Device.default).to eq(device)
    end
  end
end