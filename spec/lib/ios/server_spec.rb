describe Calabash::IOS::Server do

  it '.default' do
    stub_const('Calabash::IOS::Environment::DEVICE_ENDPOINT',
               URI.parse('http://foo.bar:22'))

    server = Calabash::IOS::Server.default
    expect(server).to be_a_kind_of(Calabash::IOS::Server)
    expect(server.endpoint.to_s).to be == 'http://foo.bar:22'
  end

  describe '#localhost?' do
    describe 'returns true if endpoint hostname is' do
      it 'localhost' do
        server = Calabash::IOS::Server.new(URI.parse('http://localhost'))
        expect(server.localhost?).to be_truthy
      end

      it '127.0.0.1' do
        server = Calabash::IOS::Server.new(URI.parse('http://127.0.0.1'))
        expect(server.localhost?).to be_truthy
      end
    end

    it 'returns true if not localhost or 127.0.0.1' do
      server = Calabash::IOS::Server.new(URI.parse('http://denis.local'))
      expect(server.localhost?).to be_falsey
    end
  end
end
