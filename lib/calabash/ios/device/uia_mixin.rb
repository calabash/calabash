module Calabash
  module IOS

    # !@visibility private
    module UIAMixin

      def evaluate_uia(script)
        uia_serialize_and_call(script)
      end
    end
  end
end
