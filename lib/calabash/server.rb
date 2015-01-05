module Calabash
  class Server
    attr_reader :endpoint
    attr_reader :test_server_port

    def initialize(endpoint, test_server_port)
      @endpoint = endpoint
      @test_server_port = test_server_port
    end
  end
end
