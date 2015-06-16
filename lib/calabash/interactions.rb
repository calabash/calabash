module Calabash
  module Interactions
    # @todo Needs docs!
    def query(query, *args)
      Calabash::Device.default.map_route(query, :query, *args)
    end

    # @todo Needs docs!
    def flash(query)
      Calabash::Device.default.map_route(query, :flash)
    end
  end
end
