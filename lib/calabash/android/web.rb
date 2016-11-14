module Calabash
  module Android
    module Web
      # @!visibility private
      define_method(:_evaluate_javascript_in) do |query, javascript|
        Calabash::Internal.with_default_device(required_os: :android) do |device|
          device.evaluate_javascript_in(query, javascript)
        end
      end
    end
  end
end