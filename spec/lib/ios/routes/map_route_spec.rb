describe Calabash::IOS::Routes::MapRoute do

  let(:route_error) { Calabash::IOS::Routes::MapRouteError }

  let(:route) do
    Class.new do
      include Calabash::IOS::Routes::MapRoute
      attr_reader :http_client
      @http_client =  Class.new do
        def post(_, _); ; end
      end.new
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
    expect(route.send(:make_map_parameters, 'query', 'name', 'args')).to be == expected
  end

  describe '#make_map_request' do
    it "makes a 'map' request" do
      expect(route).to receive(:make_map_parameters).with('query', 'name', 'args').and_return({})
      request = route.send(:make_map_request, 'query', 'name', 'args')
      expect(request).to be_a_kind_of Calabash::HTTP::Request
      expect(request.route).to be == 'map'
      expect(request.params).to be == '{}'
    end

    it 'raises an error if a request cannot be made' do
      expect(route).to receive(:make_map_parameters).with('query', 'name', 'args').and_return({})
      expect(Calabash::HTTP::Request).to receive(:request).and_raise StandardError
      expect do
        route.send(:make_map_request, 'query', 'name', 'args')
      end.to raise_error route_error
    end
  end

  it '#post' do
    request = Calabash::HTTP::Request.new('map', 'JSON')
    expect(route.http_client).to receive(:post).with(request).and_return 'response'
    expect(route.send(:post, request)).to be == 'response'
  end

  describe '#handle_response' do

    let(:body) { {} }

    before { expect(response).to receive(:body).and_return(body) }

    describe 'raises errors if' do
      it 'parsing body raises TypeError' do
        expect(JSON).to receive(:parse).with(body).and_raise TypeError
        expect do
          route.send(:handle_response, response, 'query')
        end.to raise_error route_error
      end

      it 'parsing body raises JSON::ParseError' do
        expect(JSON).to receive(:parse).with(body).and_raise JSON::ParserError
        expect do
          route.send(:handle_response, response, 'query')
        end.to raise_error route_error
      end

      it 'parsed body outcome key value is not SUCCESS or FAILURE' do
        expect(JSON).to receive(:parse).with(body).and_return({'outcome' => 'invalid value'})
        expect do
          route.send(:handle_response, response, 'query')
        end.to raise_error route_error
      end
    end

    it "calls 'success' when outcome is 'SUCCESS'" do
      hash = {'outcome' => 'SUCCESS'}
      expect(JSON).to receive(:parse).with(body).and_return(hash)
      expect(route).to receive(:success).with(hash, 'query').and_return 'query results'
      expect(route.send(:handle_response, response, 'query')).to be == 'query results'
    end

    it "calls 'failure' when outcome is 'FAILURE'" do
      hash = {'outcome' => 'FAILURE'}
      expect(JSON).to receive(:parse).with(body).and_return(hash)
      expect(route).to receive(:failure).with(hash, 'query').and_raise route_error
      expect do
        route.send(:handle_response, response, 'query')
      end.to raise_error route_error
    end
  end


  it '#failure' do
    expect do
      route.send(:failure, {}, 'query')
    end.to raise_error route_error

    expect do
      route.send(:failure, {'reason' => 'reason'}, 'query')
    end.to raise_error route_error

    expect do
      route.send(:failure, {'reason' => ''}, 'query')
    end.to raise_error route_error

    expect do
      route.send(:failure, {'details' => 'details'}, 'query')
    end.to raise_error route_error

    expect do
      route.send(:failure, {'details' => ''}, 'query')
    end.to raise_error route_error
  end

  it '#success' do
    hash = {'results' => []}
    actual = route.send(:success, hash, 'query')
    expect(actual).to be_a_kind_of Calabash::QueryResult
    expect(actual.query).to be == 'query'
    expect(actual).to be == []
  end
end
