describe Calabash::HTTP::RetriableClient do
  let(:endpoint) {'http://localhost:4000'}
  let(:server) {Calabash::Server.new(URI.parse(endpoint), 2000)}
  let(:retriable_http_client) {Calabash::HTTP::RetriableClient.new(server)}

  describe '#get' do
    before do
      allow(Retriable).to receive(:retriable).and_yield
    end

    it 'should be able to make an http call using the client' do
      client = retriable_http_client.instance_variable_get(:@client)
      route = 'my-route/to-my-server'
      request = Calabash::HTTP::Request.new(route)
      expected_http_route = server.endpoint + request.route

      expect(client).to receive(:get).with(expected_http_route, {})

      retriable_http_client.get(request)
    end

    it 'should be able to make an http call with parameters' do
      client = retriable_http_client.instance_variable_get(:@client)
      route = 'my-route/to-my-server'
      params = {'my-param' => 'my-value'}
      request = Calabash::HTTP::Request.new(route, params)
      expected_http_route = server.endpoint + route

      expect(client).to receive(:get).with(expected_http_route, params)

      retriable_http_client.get(request)
    end

    it 'should return the value returned by the client' do
      client = retriable_http_client.instance_variable_get(:@client)
      route = 'my-route/to-my-server'
      request = Calabash::HTTP::Request.new(route)
      expected_value = :my_value

      allow(client).to receive(:get).and_return(expected_value)

      expect(retriable_http_client.get(request)).to eq(expected_value)
    end

    it 'should retry all if its requests with the given parameters' do
      route = 'my-route/to-my-server'
      request = Calabash::HTTP::Request.new(route)
      arguments = {timeout: :my_timeout, interval: :my_interval, retries: :my_retries}
      expected_arguments = {timeout: :my_timeout, interval: :my_interval, tries: :my_retries}

      expect(Retriable).to receive(:retriable).with(hash_including(expected_arguments)).and_return(true)

      retriable_http_client.get(request, arguments)
    end

    it 'should always raise a Calabash::HTTP::Error if an error is raised in the client call' do
      client = retriable_http_client.instance_variable_get(:@client)
      route = 'my-route/to-my-server'
      request = Calabash::HTTP::Request.new(route)
      error_message = 'my error message'

      allow(client).to receive(:get).and_raise(RuntimeError, error_message)
      expect{retriable_http_client.get(request)}.to raise_error(Calabash::HTTP::Error, error_message)

      allow(client).to receive(:get).and_raise(StandardError, error_message)
      expect{retriable_http_client.get(request)}.to raise_error(Calabash::HTTP::Error, error_message)

      allow(client).to receive(:get).and_raise(Exception, error_message)
      expect{retriable_http_client.get(request)}.to raise_error(Exception, error_message)
    end
  end
end
