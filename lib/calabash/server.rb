module Calabash
  class Server
    attr_reader :url

    def initialize(url)
      @url = url
    end
  end
end
