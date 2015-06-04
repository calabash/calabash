describe Calabash::HTTP::RetriableClient do
  let(:endpoint) { 'http://localhost:4000' }
  let(:server) { Calabash::Server.new(URI.parse(endpoint), 2000) }
  let(:client) { Calabash::HTTP::RetriableClient.new(server) }
  let(:request) do
    Class.new do
      def route; 'route'; end
      def params; JSON.generate([]); end
    end.new
  end

  describe '.new' do
    it 'sets the instance variables' do
      expect(::HTTPClient).to receive(:new).and_return :new
      expect(client.client).to be == :new
      expect(client.instance_variable_get(:@client)).to be == :new
      expect(client.instance_variable_get(:@server)).to be == server
      expect(client.instance_variable_get(:@retries)).to be_truthy
      expect(client.instance_variable_get(:@timeout)).to be_truthy
      expect(client.instance_variable_get(:@interval)).to be_truthy
      expect(client.instance_variable_get(:@logger)).to be_truthy
    end

    it 'respects the options' do
      options =
            {
                  client: :client,
                  retries: :retries,
                  timeout: :timeout,
                  interval: :interval,
                  logger: :logger
            }
      client = Calabash::HTTP::RetriableClient.new(server, options)
      expect(client.instance_variable_get(:@client)).to be == :client
      expect(client.instance_variable_get(:@retries)).to be == :retries
      expect(client.instance_variable_get(:@timeout)).to be == :timeout
      expect(client.instance_variable_get(:@interval)).to be == :interval
      expect(client.instance_variable_get(:@logger)).to be == :logger
    end
  end

  it '#get' do
    expect(client).to receive(:request).with(request, :get, {}).and_return []

    expect(client.get(request, {})).to be_truthy
  end

  it '#post' do
    expect(client).to receive(:request).with(request, :post, {}).and_return []

    expect(client.post(request, {})).to be_truthy
  end
end
