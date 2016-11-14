module Calabash
  module IOS
    module Web
      # @!visibility private
      define_method(:_evaluate_javascript_in) do |query, javascript|
        query(query, calabashStringByEvaluatingJavaScript: javascript)
      end
    end
  end
end