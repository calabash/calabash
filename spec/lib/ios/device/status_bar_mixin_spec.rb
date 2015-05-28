describe Calabash::IOS::StatusBarMixin do

  let(:device) do
    Class.new do
      include Calabash::IOS::StatusBarMixin

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
end
