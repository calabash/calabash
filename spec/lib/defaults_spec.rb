describe Calabash::Defaults do
  let(:world) do
    Class.new do
      require 'calabash'
      include Calabash
    end.new
  end

  let(:dummy_device) do
    Class.new(Calabash::Device) do
      def initialize

      end
    end.new
  end

  describe '#default_device' do
    it 'should return the default device' do
      expected = :expected

      expect(Calabash::Device).to receive(:default).and_return(expected)

      expect(world.default_device).to eq(expected)
    end
  end

  describe '#default_device=' do
    it 'should set the default device' do
      expected = :expected

      expect(Calabash::Device).to receive(:default=).once.with(expected)

      world.default_device = expected
    end
  end


  describe '#default_application' do
    it 'should return the default application' do
      expected = :expected

      expect(Calabash::Application).to receive(:default).and_return(expected)

      expect(world.default_application).to eq(expected)
    end
  end

  describe '#default_application=' do
    it 'should set the default application' do
      expected = :expected

      expect(Calabash::Application).to receive(:default=).once.with(expected)

      world.default_application = expected
    end
  end

  describe '#default_server' do
    it 'should return server of the default device' do
      expected = :expected

      allow(world).to receive(:default_device).and_return(dummy_device)
      expect(dummy_device).to receive(:server).and_return(expected)

      expect(world.default_server).to eq(expected)
    end

    it 'should fail if the default device is not set' do
      allow(world).to receive(:default_device).and_return(nil)

      expect{world.default_server}.to raise_error(RuntimeError, 'No default device set')
    end
  end

  describe '#default_server=' do
    it 'should change the server of the default device' do
      expected = :expected

      allow(world).to receive(:default_device).and_return(dummy_device)
      expect(dummy_device).to receive(:change_server).with(expected)

      world.default_server = expected
    end
  end
end
