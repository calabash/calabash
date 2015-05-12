describe Calabash::IOS::Server do

  it '.default' do
    stub_const('Calabash::IOS::Environment::DEVICE_ENDPOINT',
               URI.parse('http://foo.bar:22'))
    server = Calabash::IOS::Server.default
    expect(server).to be_a_kind_of(Calabash::IOS::Server)
    expect(server.endpoint.to_s).to be == 'http://foo.bar:22'
  end
end
