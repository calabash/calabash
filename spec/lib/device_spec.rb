require 'uri'

describe Calabash::Device do
  let(:identifier) {:my_identifier}
  let(:server) {Calabash::Server.new(URI.parse('http://localhost:100'), 200)}

  let(:device) {Calabash::Device.new(identifier, server)}

  describe '#install' do
    it 'should invoke the managed impl if running in a managed env' do
      params = {my: :param}
      expected_params = params.merge({device: device})

      allow(Calabash::Managed).to receive(:managed?).and_return(true)
      expect(device).not_to receive(:_install)
      expect(Calabash::Managed).to receive(:install).with(expected_params)

      device.install(params)
    end

    it 'should invoke its own impl unless running in a managed env' do
      params = {my: :param}

      allow(Calabash::Managed).to receive(:managed?).and_return(false)
      expect(device).to receive(:_install).with(params)
      expect(Calabash::Managed).not_to receive(:install)

      device.install(params)
    end
  end

  describe '#uninstall' do
    it 'should invoke the managed impl if running in a managed env' do
      params = {my: :param}
      expected_params = params.merge({device: device})

      allow(Calabash::Managed).to receive(:managed?).and_return(true)
      expect(device).not_to receive(:_uninstall)
      expect(Calabash::Managed).to receive(:uninstall).with(expected_params)

      device.uninstall(params)
    end

    it 'should invoke its own impl unless running in a managed env' do
      params = {my: :param}

      allow(Calabash::Managed).to receive(:managed?).and_return(false)
      expect(device).to receive(:_uninstall).with(params)
      expect(Calabash::Managed).not_to receive(:uninstall)

      device.uninstall(params)
    end
  end

  describe '#_install' do
    it 'should have an abstract implementation' do
      params = {my: :param}

      expect{device.send(:_install, params)}.to raise_error(Calabash::AbstractMethodError)
    end
  end

  describe '#_uninstall' do
    it 'should have an abstract implementation' do
      params = {my: :param}

      expect{device.send(:_uninstall, params)}.to raise_error(Calabash::AbstractMethodError)
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
