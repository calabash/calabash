module Calabash
  module IOS

    # !@visibility private
    module UIAMixin

      def evaluate_uia(script)
        uia_route(script)
      end
    end
  end
end
