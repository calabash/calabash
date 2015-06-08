module Calabash
  module HTTP

    # Raised when there is a problem communicating with the Calabash test
    # server.
    class Error < StandardError

    end

    # Raised when there is a problem creating an HTTP request.
    class RequestError < StandardError

    end
  end
end
