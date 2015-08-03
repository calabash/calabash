module Calabash
  module IOS
    # @!visibility private
    module Interactions
      # @!visibility private
      def _evaluate_javascript_in(query, javascript)
        query(query, calabashStringByEvaluatingJavaScript: javascript)
      end
    end
  end
end
