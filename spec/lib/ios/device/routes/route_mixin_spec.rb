describe Calabash::IOS::Routes::RouteMixin do

  let(:error_class) { Calabash::IOS::Routes::RouteError }

  let(:device) do
    Class.new do
      include Calabash::IOS::Routes::RouteMixin

      attr_reader :http_client

      def initialize
        @http_client = Class.new do
          def post(_); ; end;
        end.new
      end
    end.new
  end

  let(:response) do
    Class.new do
      def body; ; ; end
    end.new
  end

  describe '#route_post_request' do
    it 'calls http_client.post' do
      expect(device.http_client).to receive(:post).with('request').and_return 'response'

      expect(device.send(:route_post_request, 'request')).to be == 'response'
    end

    it "does not re-raise errors raised by 'post'" do
      expect(device.http_client).to receive(:post).with('request').and_raise ArgumentError

      expect do
        device.send(:route_post_request, 'request')
      end.to raise_error error_class
    end
  end

  describe '#route_handle_response' do

    let(:body) { {} }

    before { expect(response).to receive(:body).and_return(body) }

    describe 'raises errors if' do
      it 'parsing body raises TypeError' do
        expect(JSON).to receive(:parse).with(body).and_raise TypeError

        expect do
          device.send(:route_handle_response, response, 'query')
        end.to raise_error error_class
      end

      it 'parsing body raises JSON::ParseError' do
        expect(JSON).to receive(:parse).with(body).and_raise JSON::ParserError

        expect do
          device.send(:route_handle_response, response, 'query')
        end.to raise_error error_class
      end

      it 'parsed body outcome key value is not SUCCESS or FAILURE' do
        expect(JSON).to receive(:parse).with(body).and_return({'outcome' =>
                                                                     'invalid value'})
        expect do
          device.send(:route_handle_response, response, 'query')
        end.to raise_error error_class
      end
    end

    it "calls 'success' when outcome is 'SUCCESS'" do
      hash = {'outcome' => 'SUCCESS'}
      expect(JSON).to receive(:parse).with(body).and_return(hash)
      expect(device).to receive(:route_success).with(hash, 'query').and_return 'query results'

      actual = device.send(:route_handle_response, response, 'query')
      expect(actual).to be == 'query results'
    end

    it "calls 'failure' when outcome is 'FAILURE'" do
      hash = {'outcome' => 'FAILURE'}
      expect(JSON).to receive(:parse).with(body).and_return(hash)
      expect(device).to receive(:route_failure).with(hash, 'query').and_raise error_class

      expect do
        device.send(:route_handle_response, response, 'query')
      end.to raise_error error_class
    end
  end


  it '#route_failure' do
    expect do
      device.send(:route_failure, {}, 'query')
    end.to raise_error error_class

    expect do
      device.send(:route_failure, {'reason' => 'reason'}, 'query')
    end.to raise_error error_class

    expect do
      device.send(:route_failure, {'reason' => ''}, 'query')
    end.to raise_error error_class

    expect do
      device.send(:route_failure, {'details' => 'details'}, 'query')
    end.to raise_error error_class

    expect do
      device.send(:route_failure, {'details' => ''}, 'query')
    end.to raise_error error_class
  end

  it '#route_success' do
    hash = {'results' => []}
    actual = device.send(:route_success, hash, 'query')
    expect(actual).to be_a_kind_of Calabash::QueryResult
    expect(actual.query).to be == 'query'
    expect(actual).to be == []
  end
end
