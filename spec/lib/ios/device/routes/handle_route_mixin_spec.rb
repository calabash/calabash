describe Calabash::IOS::Routes::HandleRouteMixin do

  let(:error_class) { Calabash::IOS::RouteError }

  let(:device) do
    Class.new do
      include Calabash::IOS::Routes::HandleRouteMixin
      include Calabash::IOS::Routes::ResponseParser

      attr_reader :http_client

      def initialize
        @http_client = Class.new do
          def post(_, _={}); ; end;
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
    let (:request) do
      Class.new do
        def params; 'parameter' ; end
      end.new
    end

    it 'calls http_client.post' do
      expect(device.http_client).to receive(:post).with(request).and_return 'response'

      expect(device.send(:route_post_request, request)).to be == 'response'
    end

    it "does not re-raise errors raised by 'post'" do
      expect(device.http_client).to receive(:post).with(request).and_raise ArgumentError

      expect do
        device.send(:route_post_request, request)
      end.to raise_error error_class
    end

    it 'sets the timeout to 30 if route is flash' do
      json = "{\"operation\":{\"method_name\":\"flash\",\"arguments\":[]},\"query\":\"button\"}"
      expect(request).to receive(:params).and_return(json)
      expect(device.http_client).to receive(:post).with(request, {timeout: 30}).and_return 'response'

      expect(device.send(:route_post_request, request)).to be == 'response'
    end
  end

  describe '#route_handle_response' do

    let(:body) { {} }

    before { expect(response).to receive(:body).and_return(body) }

    it "calls 'success' when outcome is 'SUCCESS'" do
      hash = {'outcome' => 'SUCCESS', 'results' => [1]}
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

  describe '#route_success' do
    let(:hash) { {'results' => []} }

    it 'returns a query result if query is not nil' do
      actual = device.send(:route_success, hash, "my query")
      expect(actual).to be_a_kind_of Calabash::QueryResult
      expect(actual.query.to_s).to be == 'my query'
      expect(actual).to be == []
    end

    it 'returns an Array if query is nil' do
      actual = device.send(:route_success, hash, nil)
      expect(actual).to be_a_kind_of Array
      expect(actual).to be == []
    end
  end
end
