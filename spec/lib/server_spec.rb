describe Calabash::Server do
  let(:endpoint) {:endpoint}
  let(:test_server_port) {200}

  it 'should initialize using an endpoint and a test server port as its first and second parameter' do
    Calabash::Server.new(endpoint, test_server_port)
  end

  it 'should save the endpoint given when initialized and return it' do
    server = Calabash::Server.new(endpoint, test_server_port)

    expect(server.endpoint).to eq(endpoint)
  end

  it 'should save the test server port given when initialized and return it' do
    server = Calabash::Server.new(endpoint, test_server_port)

    expect(server.test_server_port).to eq(test_server_port)
  end
end
