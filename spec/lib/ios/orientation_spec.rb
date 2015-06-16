describe Calabash::IOS::Orientation do

  let(:device) do
    Class.new do
      def status_bar_orientation; ; end
    end.new
  end

  let(:world) do
    Class.new do
      require 'calabash/ios'
      include Calabash::IOS
    end.new
  end

  before do
    allow(Calabash::Device).to receive(:default).and_return device
  end

  it '#status_bar_orientation' do
    expect(Calabash::Device).to receive(:default).and_return device
    expect(device).to receive(:status_bar_orientation).and_return 'o'

    expect(world.status_bar_orientation).to be == 'o'
  end

  describe '#_portrait?' do
    it 'down' do
      expect(world).to receive(:status_bar_orientation).and_return 'down'

      expect(world._portrait?).to be == true
    end

    it 'up' do
      expect(world).to receive(:status_bar_orientation).and_return 'up'

      expect(world._portrait?).to be == true
    end

    it 'left' do
      expect(world).to receive(:status_bar_orientation).and_return 'left'

      expect(world._portrait?).to be == false
    end

    it 'right' do
      expect(world).to receive(:status_bar_orientation).and_return 'right'

      expect(world._portrait?).to be == false
    end
  end

  describe '#_landscape?' do
    it 'down' do
      expect(world).to receive(:status_bar_orientation).and_return 'down'

      expect(world._landscape?).to be == false
    end

    it 'up' do
      expect(world).to receive(:status_bar_orientation).and_return 'up'

      expect(world._landscape?).to be == false
    end

    it 'left' do
      expect(world).to receive(:status_bar_orientation).and_return 'left'

      expect(world._landscape?).to be == true
    end

    it 'right' do
      expect(world).to receive(:status_bar_orientation).and_return 'right'

      expect(world._landscape?).to be == true
    end
  end
end
