module Calabash
  module IOS

    # Scrolling gestures for UIScrollView, UITableView, MKMapView, UIWebView,
    # WKWebView, and UICollectionView.
    #
    # Starting iOS, Apple's official UIAutomation API has been broken on the
    # iOS Simulators for these methods:
    #
    #  * dragInsideWithOptions
    #  * flickInsideWithOptions
    #
    # The result is that gestures like swipe and flick do not work on
    # iOS Simulators.
    #
    # Calabash iOS implements several scrolling methods that allow you to work
    # around these bugs.
    #
    # @see Calabash::Gestures#pan
    # @see Calabash::Gestures#flick
    module Scroll

      # Scrolls the first view matching `query` in `direction`.
      #
      # View are scrolled half of their frame size.
      #
      # If `query` matches a view that is not a  UIScrollView or a subclass, an
      # error will be raised. UITableView, MKMapView, UIWebView, WKWebView, and
      # UICollectionView are all examples of subclasses of UIScrollView.
      #
      # An error will be raised if more than on view is matched by `query`.
      #
      # To avoid matching more than one UIScrollView (or subclass):
      #  * Make the query more specific: "UITableView marked:'table'"
      #  * Use the index language feature:  "UIScrollView index:0"
      #
      # @example
      #   scroll("UITableView", :down)
      #
      # @note This is implemented by calling the Objective-C
      #  `setContentOffset:animated:` method and can do things users cannot.
      #
      # This is the only alternative for `pan` and `flick` which do not work
      # on iOS Simulators starting with iOS 7.
      #
      # @see Calabash::Gestures#pan
      # @see Calabash::Gestures#flick
      #
      # @param [String,Query,Hash] query A query describing the view to scroll.
      # @param [Symbol] direction The direction to scroll. Valid directions are:
      #   'up', 'down', 'left', and 'right'
      #
      # @raise [ArgumentError] If direction is invalid.
      # @raise [ArgumentError] If query is invalid.
      # @raise [ViewNotFoundError] If query matches no views.
      # @raise [RuntimeError] If query matches more than one view.
      # @raise [RuntimeError] If query matches a view that is not a UIScrollView.
      def scroll(query, direction)
        allowed_directions = [:up, :down, :left, :right]
        dir_symbol = direction.to_sym
        unless allowed_directions.include?(dir_symbol)
          raise ArgumentError,
                "Expected '#{direction}' to be one of #{allowed_directions.join(',')}"
        end

        Query.ensure_valid_query(query)

        begin
          view_to_scroll = _wait_for_exactly_one_scroll_view(query)
        rescue RuntimeError => e
          raise RuntimeError, e
        end

        results = Device.default.map_route(query, :scroll, direction)

        if results.first.nil?
          fail("Expected '#{query}' to match a UIScrollView or a subclass")
        end

        Calabash::QueryResult.create([view_to_scroll], query)
      end

      # Scroll the UITableView matching `query` to `row` in `section`.
      #
      # If `query` matches a view that is not a UITableView or a subclass, an
      # error will be raised.
      #
      # An error will be raised if more than on view is matched by `query`.
      #
      # To avoid matching more than one UITableView (or subclass):
      #  * Make the query more specific:  "UITableView marked:'table'"
      #  * Use the index language feature:  "UITableView index:1"
      #
      # Row and section are zero indexed.  The first row is row 0.
      #
      # @example
      #  # Scroll to the 5th row in the first section.
      #  > scroll_to_row("UITableView", 5)
      #
      #  # Scroll to the 3rd row, in the 5th section
      #  > scroll_to_row("UITableView", 3, 5)
      #
      # @note This is implement by calling the Objective-C
      #  `scrollToRowAtIndexPath:atScrollPosition:animated:` method and can do
      #   things that users cannot.
      #
      # This is the only alternative for `pan` and `flick` which do not work
      # on iOS Simulators starting with iOS 7.
      #
      # @see Calabash::Gestures#pan
      # @see Calabash::Gestures#flick
      #
      # @param [String,Query,Hash] query A query describing the table to scroll.
      # @param [Numeric] row The row number to scroll to.
      # @param [Numeric] section The section number to scroll to.
      # @param [Hash] options Options to control the scroll behavior.
      # @option options [Symbol] :scroll_position (:middle) The final position
      #  of the row in the view.  Can be :top, :middle, :bottom
      # @option options [Boolean] :animate (true)  Should the scrolling be
      #  animated?
      #
      # @raise [ArgumentError] If the :scroll_position is invalid.
      # @raise [ArgumentError] If the :animate key is not a Boolean.
      # @raise [ArgumentError] If query is invalid.
      # @raise [ViewNotFoundError] If query matches no views.
      # @raise [RuntimeError] If query matches more than one view.
      # @raise [RuntimeError] If query matches a view that is not a UITableView.
      # @raise [RuntimeError] If the row and section are invalid for the table.
      def scroll_to_row(query, row, section=0, **options)
        default_options = {
          :scroll_position => :middle,
          :animate => true
        }

        merged_options = default_options.merge(options)

        begin
          _expect_valid_scroll_options(VALID_TABLE_SCROLL_POSITIONS, merged_options)
        rescue ArgumentError => e
          raise ArgumentError, e
        end

        Query.ensure_valid_query(query)

        begin
          view_to_scroll = _wait_for_exactly_one_scroll_view(query)
        rescue RuntimeError => e
          raise RuntimeError, e
        end

        position = merged_options[:scroll_position].to_sym
        animate = merged_options[:animate]

        results = Device.default.map_route(query, :scrollToRow, row.to_i,
                                          section.to_i, position, animate)

        if results.first.nil?
          message = [
                "Could not scroll table to row '#{row}' and section '#{section}'.",
                "Either query '#{query}' did not match a UITableView or",
                "the row '#{row}' in section '#{section}' does not exist."
          ].join("\n")
          fail(message)
        end

        Calabash::QueryResult.create([view_to_scroll], query)
      end

      # Scroll the UITableView matching `query` to the row with `mark`.  This
      # method is particularly useful when testing tables with dynamic content.
      #
      # An error will be raised If `query` matches a view that is not a
      # UITableView or a subclass.
      #
      # To avoid matching more than one UITableView (or subclass):
      #  * Make the query more specific:  "UITableView marked:'table'"
      #  * Use the index language feature:  "UITableView index:1"
      #
      # The `mark` can be on any subview in a UITableViewCell or the cell
      # itself.  If no cell with `mark` can be found, an error will be raised.
      #
      # @example
      #  > scroll_to_row_with_mark("UITableView", "apples")
      #
      # @note This is implement by calling the Objective-C
      #  `scrollToRowAtIndexPath:atScrollPosition:animated:` method and can do
      #   things that users cannot.  The implementation generates a new cell
      #   for every index path in your table.  This can cause performance
      #   issues if your table is very large.
      #
      # This is the only alternative for `pan` and `flick` which do not work
      # on iOS Simulators starting with iOS 7.
      #
      # @see Calabash::Gestures#pan
      # @see Calabash::Gestures#flick
      #
      # @param [String,Query,Hash] query A query describing the table to scroll.
      # @param [String] mark The cell identifier.
      # @param [Hash] options Options to control the scroll behavior.
      # @option options [Symbol] :scroll_position (:middle) The final position
      #  of the row in the view.  Can be :top, :middle, :bottom
      # @option options [Boolean] :animate (true)  Should the scrolling be
      #  animated?
      #
      # @raise [ArgumentError] If mark is nil or the empty string.
      # @raise [ArgumentError] If the :scroll_position is invalid.
      # @raise [ArgumentError] If the :animate key is not a Boolean.
      # @raise [ArgumentError] If query is invalid.
      # @raise [ViewNotFoundError] If query matches no views.
      # @raise [RuntimeError] If query matches more than one view.
      # @raise [RuntimeError] If query matches a view that is not a UITableView.
      # @raise [RuntimeError] If no cell with `mark` is found.
      def scroll_to_row_with_mark(query, mark, options={})
        default_options = {
              :scroll_position => :middle,
              :animate => true
        }

        merged_options = default_options.merge(options)

        begin
          _expect_valid_scroll_options(VALID_TABLE_SCROLL_POSITIONS, merged_options)
          _expect_valid_scroll_mark(mark)
        rescue ArgumentError => e
          raise ArgumentError, e
        end

        Query.ensure_valid_query(query)

        begin
          view_to_scroll = _wait_for_exactly_one_scroll_view(query)
        rescue RuntimeError => e
          raise RuntimeError e
        end

        position = merged_options[:scroll_position].to_sym
        animate = merged_options[:animate]

        results = Device.default.map_route(query, :scrollToRowWithMark, mark,
                                          position, animate)

        if results.first.nil?
          message = [
                "Could not scroll table to row with mark: '#{mark}'",
                "Either the '#{query}' did not match a UITableView or",
                "there is no cell with mark '#{mark}'."
          ].join("\n")
          fail(message)
        end

        Calabash::QueryResult.create([view_to_scroll], query)
      end

      # Scrolls the UICollectionView matching `query` to `item` in `section`.
      #
      # If `query` matches a view that is not a UICollectionView or a subclass,
      # an error will be raised.
      #
      # An error will be raised if more than on view is matched by `query`.
      #
      # To avoid matching more than one UICollectionView (or subclass):
      #  * Make the query more specific:  "UICollectionView marked:'gallery'"
      #  * Use the index language feature:  "UICollectionView index:1"
      #
      #
      # Item and section are zero indexed.  The first item is 0.
      #
      # @example
      #  # Scroll to the 5th item in the first section.
      #  > scroll_to_item("UICollectionView", 5)
      #
      #  # Scroll to the 3rd row, in the 5th section
      #  > scroll_to_item("UICollectionView", 3, 5)
      #
      # @example The following are the allowed :scroll_position values.
      #  :top, :center_vertical, :bottom, :left, :center_horizontal, :right
      #
      # @note This is implement by calling the Objective-C
      #  `scrollToItemAtIndexPath:atScrollPosition:animated:` method and can do
      #   things that users cannot.
      #
      # This is the only alternative for `pan` and `flick` which do not work
      # on iOS Simulators starting with iOS 7.
      #
      # @see Calabash::Gestures#pan
      # @see Calabash::Gestures#flick
      #
      # @param [String,Query,Hash] query A query describing the table to scroll.
      # @param [Numeric] item The item number to scroll to.
      # @param [Numeric] section The section number to scroll to.
      # @param [Hash] options Options to control the scroll behavior.
      # @option options [Symbol] :scroll_position (:top) The final position
      #  of the row in the view.  See the examples for valid positions.
      # @option options [Boolean] :animate (true)  Should the scrolling be
      #  animated?
      #
      # @raise [ArgumentError] If the :scroll_position is invalid.
      # @raise [ArgumentError] If the :animate key is not a Boolean.
      # @raise [ArgumentError] If query is invalid.
      # @raise [ViewNotFoundError] If query matches no views.
      # @raise [RuntimeError] If query matches more than one view.
      # @raise [RuntimeError] If query matches a view that is not a
      #   UICollectionView.
      # @raise [RuntimeError] If the item and section are not valid for
      #   the collection.
      def scroll_to_item(query, item, section=0, **options)
        default_options = {
              :scroll_position => :top,
              :animate => true
        }

        merged_options = default_options.merge(options)

        begin
          _expect_valid_scroll_options(VALID_COLLECTION_SCROLL_POSITIONS, merged_options)
        rescue ArgumentError => e
          raise ArgumentError, e
        end

        Query.ensure_valid_query(query)

        begin
          view_to_scroll = _wait_for_exactly_one_scroll_view(query)
        rescue RuntimeError => e
          raise RuntimeError e
        end

        position = merged_options[:scroll_position].to_sym
        animate = merged_options[:animate]

        results = Device.default.map_route(query, :collectionViewScroll,
                                           item.to_i, section.to_i,
                                           position, animate)
        if results.first.nil?
          message = [
                "Could not scroll collection to item '#{item}' and section '#{section}'.",
                "Either query '#{query}' did not match a UICollectionView or",
                "the item '#{item}' in section '#{section}' does not exist."
          ].join("\n")
          fail(message)
        end

        Calabash::QueryResult.create([view_to_scroll], query)
      end

      # Scroll the UICollectionView matching `query` to the row with `mark`.
      # This method is particularly useful when testing collections with dynamic
      # content.
      #
      # An error will be raised If `query` matches a view that is not a
      # UICollectionView or a subclass.
      #
      # To avoid matching more than one UICollectionView (or subclass):
      #  * Make the query more specific:  "UICollectionView marked:'gallery'"
      #  * Use the index language feature:  "UICollectionView index:1"
      #
      # The `mark` can be on any subview in a UICollectionViewCell or the cell
      # itself.  If no cell with `mark` can be found, an error will be raised.
      #
      # @example
      #  > scroll_to_item_with_mark("UICollectionView", "mom")
      #
      # @example The following are the allowed :scroll_position values.
      #  :top, :center_vertical, :bottom, :left, :center_horizontal, :right
      #
      # @note This is implement by calling the Objective-C
      #  `scrollToRowAtIndexPath:atScrollPosition:animated:` method and can do
      #   things that users cannot.  The implementation generates a new item
      #   for every index path in your collection.  This can cause performance
      #   issues if your collection is very large.
      #
      # This is the only alternative for `pan` and `flick` which do not work
      # on iOS Simulators starting with iOS 7.
      #
      # @see Calabash::Gestures#pan
      # @see Calabash::Gestures#flick
      #
      # @param [String,Query,Hash] query A query describing the collection to
      #   scroll.
      # @param [String] mark The cell identifier.
      # @param [Hash] options Options to control the scroll behavior.
      # @option options [Symbol] :scroll_position (:top) The final position
      #  of the row in the view.  See the examples for valid positions.
      # @option options [Boolean] :animate (true)  Should the scrolling be
      #  animated?
      #
      # @raise [ArgumentError] If mark is nil or the empty string.
      # @raise [ArgumentError] If the :scroll_position is invalid.
      # @raise [ArgumentError] If the :animate key is not a Boolean.
      # @raise [ArgumentError] If query is invalid.
      # @raise [ViewNotFoundError] If query matches no views.
      # @raise [RuntimeError] If query matches more than one view.
      # @raise [RuntimeError] If query matches a view that is not a
      #   UICollectionView.
      # @raise [RuntimeError] If no item with `mark` is found.
      def scroll_to_item_with_mark(query, mark, options={})
        default_options = {
              :scroll_position => :top,
              :animate => true,
        }

        merged_options = default_options.merge(options)

        begin
          _expect_valid_scroll_options(VALID_COLLECTION_SCROLL_POSITIONS, merged_options)
          _expect_valid_scroll_mark(mark)
        rescue ArgumentError => e
          raise ArgumentError, e
        end

        Query.ensure_valid_query(query)

        begin
          view_to_scroll = _wait_for_exactly_one_scroll_view(query)
        rescue RuntimeError => e
          raise RuntimeError e
        end

        position = merged_options[:scroll_position].to_sym
        animate = merged_options[:animate]

        results = Device.default.map_route(query,
                                           :collectionViewScrollToItemWithMark,
                                           mark, position, animate)

        if results.first.nil?
          message = [
                "Could not scroll collection to item with mark: '#{mark}'",
                "Either the '#{query}' did not match a UICollectionView or",
                "there is no item with mark '#{mark}'."
          ].join("\n")
          fail(message)
        end

        Calabash::QueryResult.create([view_to_scroll], query)
      end

      private

      # !@visibility private
      VALID_TABLE_SCROLL_POSITIONS = [:top, :middle, :bottom]

      # !@visibility private
      VALID_COLLECTION_SCROLL_POSITIONS = [:top, :center_vertical, :bottom,
                                           :left, :center_horizontal, :right]

      # !@visibility private
      def _wait_for_exactly_one_scroll_view(query)

        results = []

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
        results.first
      end

      # !@visibility private
      def _expect_valid_scroll_positions(valid_positions, position)
        unless valid_positions.include?(position.to_sym)
          raise ArgumentError,
                "Expected '#{position}' to be one of #{valid_positions.join(', ')}"
        end
      end

      # !@visibility private
      def _expect_valid_scroll_animate(animate)
        unless [true, false].include?(animate)
          raise ArgumentError,
                "Expected '#{animate}' to be a Boolean true or false"
        end
      end

      # !@visibility private
      def _expect_valid_scroll_options(valid_positions, options)
        _expect_valid_scroll_positions(valid_positions, options[:scroll_position])
        _expect_valid_scroll_animate(options[:animate])
      end

      # !@visibility private
      def _expect_valid_scroll_mark(mark)
        if mark.nil? || mark == ''
          raise ArgumentError,
                if mark.nil?
                  'Mark cannot be nil.'
                else
                  'Mark cannot be an empty string.'
                end
        end
      end
    end
  end
end
