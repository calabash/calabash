module Calabash
  module IOS
    module Operations

      def query(uiquery, *args)
        Calabash::IOS::Device.default.map_route(uiquery, :query, *args)
      end

    end
  end
end
