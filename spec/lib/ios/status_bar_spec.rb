describe Calabash::IOS::StatusBar do

  let(:device) do
    Class.new do
      include Calabash::IOS::StatusBar

      def map_route(_, _, _); ; end
    end.new
  end

  it '#status_bar_orientation' do
    query = '/orientation'
    route = :orientation
    parameters = :status_bar
    expect(device).to receive(:map_route).with(query, route, parameters).and_return ['o']

    expect(device.status_bar_orientation).to be == 'o'
  end

  describe '#portrait?' do
    it 'down' do
      expect(device).to receive(:status_bar_orientation).and_return 'down'

      expect(device.portrait?).to be == true
    end

    it 'up' do
      expect(device).to receive(:status_bar_orientation).and_return 'up'

      expect(device.portrait?).to be == true
    end

    it 'left' do
      expect(device).to receive(:status_bar_orientation).and_return 'left'

      expect(device.portrait?).to be == false
    end

    it 'right' do
      expect(device).to receive(:status_bar_orientation).and_return 'right'

      expect(device.portrait?).to be == false
    end
  end

  describe '#landscape?' do
    it 'down' do
      expect(device).to receive(:status_bar_orientation).and_return 'down'

      expect(device.landscape?).to be == false
    end

    it 'up' do
      expect(device).to receive(:status_bar_orientation).and_return 'up'

      expect(device.landscape?).to be == false
    end

    it 'left' do
      expect(device).to receive(:status_bar_orientation).and_return 'left'

      expect(device.landscape?).to be == true
    end

    it 'right' do
      expect(device).to receive(:status_bar_orientation).and_return 'right'

      expect(device.landscape?).to be == true
    end
  end
end
