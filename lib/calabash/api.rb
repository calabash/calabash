module Calabash
  module API

    # @todo Needs docs!
    def query(query, *args)
      Calabash::Device.default.map_route(query, :query, *args)
    end
  end
end
