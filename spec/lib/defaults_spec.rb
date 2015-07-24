describe Calabash::Defaults do
  let(:world) do
    Class.new do
      require 'calabash'
      include Calabash
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
end
