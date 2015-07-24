describe Calabash::IOS::Orientation do

  let(:device) do
    Class.new do
      def status_bar_orientation; ; end
      def rotate(_); ; end
      def rotate_home_button_to(_); ; end
      def to_s; '#<MockDevice >'; end
      def inspect; to_s; end
    end.new
  end

  let(:world) do
    Class.new do
      require 'calabash/ios'
      include Calabash::IOS
      def to_s; '#<MockWorld >'; end
      def inspect; to_s; end
    end.new
  end

  before do
    allow(Calabash::Device).to receive(:default).and_return device
  end

  it '#status_bar_orientation' do
    expect(device).to receive(:status_bar_orientation).and_return 'o'

    expect(world.status_bar_orientation).to be == 'o'
  end

  describe '#_set_orientation_landscape' do
    it 'already in landscape' do
      expect(world).to receive(:status_bar_orientation).and_return :orientation
      expect(world).to receive(:_landscape?).and_return true
      expect(world).not_to receive(:rotate_home_button_to)

      expect(world._set_orientation_landscape).to be == :orientation
    end

    it "rotates to 'right'" do
      expect(world).to receive(:_landscape?).and_return false
      expect(world).to receive(:rotate_home_button_to).with('right').and_return :orientation

      expect(world._set_orientation_landscape).to be == :orientation
    end
  end

  describe '#_set_orientation_portrait' do
    it 'already in portrait' do
      expect(world).to receive(:status_bar_orientation).and_return :orientation
      expect(world).to receive(:_portrait?).and_return true
      expect(world).not_to receive(:rotate_home_button_to)

      expect(world._set_orientation_portrait).to be == :orientation
    end

    it "rotates to 'down'" do
      expect(world).to receive(:_portrait?).and_return false
      expect(world).to receive(:rotate_home_button_to).with('down').and_return :orientation

      expect(world._set_orientation_portrait).to be == :orientation
    end
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

  describe '#rotate' do
    it 'raises error if invalid direction is passed' do
      expect do
        world.rotate 'invalid'
      end.to raise_error ArgumentError
    end

    it 'left' do
      expect(device).to receive(:rotate).with(:left).and_return true
      expect(world).to receive(:wait_for_animations)
      expect(world).to receive(:status_bar_orientation).and_return :orientation

      expect(world.rotate('left')).to be == :orientation
    end

    it 'right' do
      expect(device).to receive(:rotate).with(:right).and_return true
      expect(world).to receive(:wait_for_animations)
      expect(world).to receive(:status_bar_orientation).and_return :orientation

      expect(world.rotate('right')).to be == :orientation
    end
  end

  describe '#rotate_home_button_to' do
    it 'raises error if invalid position is passed' do
      expect do
        world.rotate_home_button_to('invalid')
      end.to raise_error ArgumentError
    end

    describe 'canonical position' do
      it "converts 'bottom' to 'down'" do
        expect(device).to receive(:rotate_home_button_to).with('down').and_return :orientation

        expect(world.rotate_home_button_to('bottom')).to be == :orientation
      end

      it "converts 'top' to 'up'" do
        expect(device).to receive(:rotate_home_button_to).with('up').and_return :orientation

        expect(world.rotate_home_button_to('top')).to be == :orientation
      end
    end
  end
end
