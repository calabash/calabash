module Calabash
  module IOS
    module Interactions
      # @!visibility private
      def _evaluate_javascript_in(query, javascript)
        query(query, calabashStringByEvaluatingJavaScript: javascript)
      end
    end
  end
end
