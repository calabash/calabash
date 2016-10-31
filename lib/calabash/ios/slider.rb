module Calabash
  module IOS

    # An interface for interacting with UISliders.
    module Slider

      # Sets the value of the first UISliders matched by `query` to `value`.
      #
      # If `query` matches a view that is not a UISlider or UISlider subclass,
      # an error will be raised.
      #
      # An error will be raised if more than on view is matched by `query`.
      #
      # To avoid matching more than one UISlider (or subclass):
      #  * Make the query more specific: "UISlider marked:'volume'"
      #  * Use the index language feature:  "UISlider index:0"
      #
      # @example
      #  slider_set_value("UISlider marked:'office slider'", 2)
      #  slider_set_value("slider marked:'weather slider'", -1)
      #  slider_set_value("UISlider", 11)
      #
      # @param [String, Hash, Calabash::Query] query A query to that indicates
      #   in which slider to set the value.
      # @param [Numeric] value The value to set the slider to.  value.to_s should
      #  produce a String representation of a Number.
      #
      # @param [options] options Options to control the behavior of the gesture.
      # @option options [Boolean] :animate (true) Animate the change.
      # @option options [Boolean] :notify_targets (true) Simulate a UIEvent by
      #  calling every target/action pair defined on the UISlider matching
      #  `query`.
      #
      # @raise [RuntimeError] When `query` does not match exactly one slider.
      # @raise [RuntimeError] When setting the value of the slider matched by
      #  `query` is not successful.
      def slider_set_value(query, value,  options={})
        Query.ensure_valid_query(query)

        default_options = {
              :animate => true,
              :notify_targets => true
        }

        merged_options = default_options.merge(options)

        found_none = "Expected '#{query}' to match exactly one view, but found no matches."
        query_object = Query.new(query)
        wait_for(found_none) do
          results = query(query_object)
          if results.length > 1
            message = [
                  "Expected '#{query}' to match exactly one view, but found '#{results.length}'",
                  results.join("\n")
            ].join("\n")
            fail(message)
          else
            results.length == 1
          end
        end

        value_str = value.to_s

        args = [merged_options[:animate], merged_options[:notify_targets]]

        Calabash::Internal.with_default_device(required_os: :ios) {|device| device.map_route(query, :changeSlider, value_str, *args)}
      end
    end
  end
end
