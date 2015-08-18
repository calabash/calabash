module Calabash
  module Android
    # Scrolling invokes methods on the views to get to the right items. This
    # behaviour is not doable by the users. For real gestures interacting with
    # the screen, see {Calabash::Gestures}.
    module Scroll
      # Scroll the first view matched by `query` in `direction`.
      #
      # @param [String, Hash, Calabash::Query] query A query describing the
      # view to scroll.
      # @param [Symbol] direction The direction to scroll. Valid directions are:
      #  :up, :down, :left, and :right
      def scroll(query, direction)
        allowed_directions = [:up, :down, :left, :right]

        dir_symbol = direction.to_sym

        unless allowed_directions.include?(dir_symbol)
          raise ArgumentError,
                "Expected '#{direction}' to be one of #{allowed_directions.join(',')}"
        end

        view = wait_for_view(query, timeout: Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT)

        result = query("#{Query.new(query)} index:0", :getFirstVisiblePosition)

        if result.length == 0
          raise "Failed to scroll view '#{query}'"
        end

        if result.first.is_a?(Hash) && result.first.has_key?("error")
          # View is not of type android.widget.AbsListView
          scroll_x = 0
          scroll_y = 0
          width = view['rect']['width']
          height = view['rect']['height']

          if direction == :up
            scroll_y = -height / 2
          elsif direction == :down
            scroll_y = height / 2
          elsif direction == :left
            scroll_x = -width / 2
          elsif direction == :right
            scroll_x = width / 2
          end

          result = query("#{Query.new(query)} index:0", {scrollBy: [scroll_x.to_i, scroll_y.to_i]})

          if result.length == 0
            raise "Failed to scroll view '#{query}'"
          end

          if result.first.is_a?(Hash) && result.first.has_key?('error')
            raise "Failed to scroll view: #{result.first['error']}"
          end
        else
          # View is of type android.widget.AbsListView
          unless [:up, :down].include?(dir_symbol)
            raise ArgumentError,
                  "Can only scroll listviews :up or :down, not #{direction}"
          end

          first_position = result.first.to_i
          result = query("#{Query.new(query)} index:0", :getLastVisiblePosition)

          if result.length == 0
            raise "Failed to scroll view '#{Query.new(query)}'"
          end

          last_position = result.first.to_i


          selection_index = if direction == :up
                              [first_position + [first_position - last_position + 1, -1].min, 0].max
                            elsif direction == :down
                              first_position + [last_position - first_position, 1].max
                            end

          result = query("#{Query.new(query)} index:0", setSelection: selection_index)

          if result.length == 0
            raise "Failed to scroll view '#{query}'"
          end
        end

        true
      end

      # Scroll to `item` in `query`. If `query` matches multiple views, the
      # first view matching `query` is scrolled.
      #
      # @param [String, Hash, Calabash::Query] query A query describing the
      #  view to scroll.
      # @param [Numeric] item The item number to scroll to. This value is
      #  0-indexed.
      def scroll_to_row(query, item)
        wait_for_view(query, timeout: Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT)
        result = query("#{Query.new(query)} index:0", setSelection: item)

        if result.length == 0
          raise "Failed to scroll view '#{query}'"
        end

        result.length.times do |i|
          if result[i].is_a?(Hash) && result[i].has_key?('error')
            raise "Unable to scroll view nr. #{i+1} matching '#{query}'. #{result[i]['error']}"
          end
        end

        true
      end
    end
  end
end
