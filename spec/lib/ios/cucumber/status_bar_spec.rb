describe Calabash::IOS::Cucumber do

  let(:device) do
    Class.new do
      def status_bar_orientation; ; end
    end.new
  end

  let(:world) do
    Class.new do
      require 'calabash/ios/cucumber'
      include Calabash::IOS::Cucumber
      def to_s
        '#<Cucumber World>'
      end

      def inspect
        to_s
      end
    end.new
  end

  it '#status_bar_orientation' do
    expect(Calabash::Device).to receive(:default).and_return device
    expect(device).to receive(:status_bar_orientation).and_return 'o'

    expect(world.status_bar_orientation).to be == 'o'
  end

  describe '#portrait?' do
    it 'down' do
      expect(world).to receive(:status_bar_orientation).and_return 'down'

      expect(world.portrait?).to be == true
    end

    it 'up' do
      expect(world).to receive(:status_bar_orientation).and_return 'up'

      expect(world.portrait?).to be == true
    end

    it 'left' do
      expect(world).to receive(:status_bar_orientation).and_return 'left'

      expect(world.portrait?).to be == false
    end

    it 'right' do
      expect(world).to receive(:status_bar_orientation).and_return 'right'

      expect(world.portrait?).to be == false
    end
  end

  describe '#landscape?' do
    it 'down' do
      expect(world).to receive(:status_bar_orientation).and_return 'down'

      expect(world.landscape?).to be == false
    end

    it 'up' do
      expect(world).to receive(:status_bar_orientation).and_return 'up'

      expect(world.landscape?).to be == false
    end

    it 'left' do
      expect(world).to receive(:status_bar_orientation).and_return 'left'

      expect(world.landscape?).to be == true
    end

    it 'right' do
      expect(world).to receive(:status_bar_orientation).and_return 'right'

      expect(world.landscape?).to be == true
    end
  end
end
