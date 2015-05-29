describe Calabash::IOS::Routes::MapRouteMixin do

  let(:route_error) { Calabash::IOS::Routes::RouteError }

  let(:device) do
    Class.new do
      include Calabash::IOS::Routes::HandleRouteMixin
      include Calabash::IOS::Routes::MapRouteMixin
    end.new
  end

  let(:response) do
    Class.new do
      def body; ; ; end
    end.new
  end

  it '#map_route_parameters' do
    expected =
          {
                :operation =>
                      {
                            :method_name => 'name',
                            :arguments => ['args']
                      },
                :query => 'query'
          }
    expect(device.send(:make_map_parameters, 'query', 'name', 'args')).to be == expected
  end

  describe '#make_map_request' do
    it "makes a 'map' request" do
      expect(device).to receive(:make_map_parameters).with('query', 'name', 'args').and_return({})

      request = device.send(:make_map_request, 'query', 'name', 'args')
      expect(request).to be_a_kind_of Calabash::HTTP::Request
      expect(request.route).to be == 'map'
      expect(request.params).to be == '{}'
    end

    it 'raises an error if a request cannot be made' do
      expect(device).to receive(:make_map_parameters).with('query', 'name', 'args').and_return({})
      expect(Calabash::HTTP::Request).to receive(:request).and_raise StandardError

      expect do
        device.send(:make_map_request, 'query', 'name', 'args')
      end.to raise_error route_error
    end
  end

  describe '#map_route' do
    describe 'raises MapRouteError when' do

      it 'posting the request raises an error' do
        expect(device).to receive(:make_map_request).and_return 'request'
        expect(device).to receive(:route_post_request).with('request').and_raise route_error

        expect do
          device.map_route('query', 'name', 'args')
        end.to raise_error route_error
      end

      it 'handling the response raises an error' do
        expect(device).to receive(:make_map_request).and_return 'request'
        expect(device).to receive(:route_post_request).with('request').and_return 'result'
        expect(device).to receive(:route_handle_response).with('result', 'query').and_raise route_error

        expect do
          device.map_route('query', 'name', 'args')
        end.to raise_error route_error
      end
    end

    it "makes an http call to the 'map' route" do
      expect(device).to receive(:make_map_request).and_return 'request'
      expect(device).to receive(:route_post_request).with('request').and_return 'result'
      expect(device).to receive(:route_handle_response).with('result', 'query').and_return []

      expect(device.map_route('query', 'name', 'args')).to be == []
    end
  end
end
