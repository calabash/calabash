describe Calabash::Server do
  let(:url) {'URL'}

  it 'should initialize using a url as its first and only parameter' do
    Calabash::Server.new(url)
  end

  it 'should save the url given when initialized and return it' do
    server = Calabash::Server.new(url)

    expect(server.url).to eq(url)
  end
end
