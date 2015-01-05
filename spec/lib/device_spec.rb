require 'uri'

describe Calabash::Device do
  let(:identifier) {:my_identifier}
  let(:server) {Calabash::Server.new(URI.parse('http://localhost:100'), 200)}

  let(:device) {Calabash::Device.new(identifier, server)}

  describe '#install' do
    it 'should have an abstract implementation' do
      expect{device.install({})}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#uninstall' do
    it 'should have an abstract implementation' do
      expect{device.uninstall({})}.to raise_error(Calabash::AbstractMethodError)
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