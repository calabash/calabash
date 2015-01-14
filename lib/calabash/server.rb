module Calabash
  class Server
    attr_reader :endpoint
    attr_reader :test_server_port

    # @param [URI] endpoint The endpoint to reach the test server.
    # @param [Integer] test_server_port The port bound to the test server
    #   running on the device.  On iOS this is same as the endpoint port.
    def initialize(endpoint, test_server_port)
      @endpoint = endpoint
      @test_server_port = test_server_port
    end
  end
end
