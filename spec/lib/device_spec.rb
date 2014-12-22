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
end