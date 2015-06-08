module Calabash
  # The base module of the Calabash public API.
  module API

    # @todo Needs docs!
    def query(query, *args)
      Calabash::Device.default.map_route(query, :query, *args)
    end
  end
end
