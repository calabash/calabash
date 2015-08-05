module Calabash
  module IOS

    # @!visibility private
    #
    # Gestures should wait for the views involved before performing the
    # gesture.
    #
    # 1. Wait for the view or views.
    # 2. Find the absolute coordinates of the gesture.
    # 3. Pass the coordinates to the Calabash UIA offset API.
    # 4. Return the views involved in the gesture as QueryResults.
    #
    # @todo Needs unit tests.
    module GesturesMixin

      # @!visibility private
      class UIAutomationError < StandardError; end

      # @!visibility private
      #
      # Since iOS 7, Apple's UIAutomation API:
      #
      #  * dragInsideWithOptions
      #  * flickInsideWithOptions
      #
      # has been broken for iOS Simulators under the following conditions:
      #
      #  * View is UIScrollView or UIScrollView subclass
      #  * View is inside a UIScrollView or UIScrollView subclass
      #
      # @todo Check for fix on iOS 9
      def check_for_broken_uia_automation(query, view, gesture_waiter)
        # Only broken for simulators.
        return if Device.default.physical_device?

        conditions = [
          # All UIScrollViews have content_offset.
          lambda do
            content_offset = gesture_waiter.query(query, :contentOffset).first
            content_offset != '*****'
          end,

          # If view looks like a table view cell.
          lambda do
            view['class'][/TableViewCell/, 0]
          end,

          # Or a collection view cell.
          lambda do
            view['class'][/CollectionViewCell/, 0]
          end,

          # If view in inside a UITableViewCell.
          lambda do
            if query.to_s == '*'
              # '*' parent UITableViewCell is too broad.
              false
            else
              new_query = "#{query} parent UITableViewCell"
              !gesture_waiter.query(new_query).empty?
            end
          end,

          # Or inside a UICollectionViewCell
          lambda do
            if query.to_s == '*'
              # '*' parent UICollectionViewCell is too broad.
              false
            else
              new_query = "#{query} parent UICollectionViewCell"
              !gesture_waiter.query(new_query).empty?
            end
          end
        ]

        if conditions.any? { |condition| condition.call }
          message = [
                '',
                "Apple's public UIAutomation API `dragInsideWithOptions` is broken for iOS Simulators >= 7",
                '',
                'If you are trying to swipe-to-delete on a simulator, it will only work on a device.',
                '',
                'If you are trying to manipulate a table, collection or scroll view, try using the Scroll API.',
                '  * scroll                    # Scroll in a direction.',
                '  * scroll_to_row             # Scroll to a row with row / section indexes.',
                '  * scroll_to_row_with_mark   # Scroll to table row with a mark.',
                '  * scroll_to_item            # Scroll to collection item with item / section indexes.',
                '  * scroll_to_item_with_mark  # Scroll to collection item with a mark.',
                '',
                'All gestures work on physical devices.'
          ].map { |msg| Color.red(msg) }.join("\n")
          raise UIAutomationError, message
        end
      end

      # @!visibility private
      def _tap(query, options={})
        view_to_touch = _gesture_waiter.wait_for_view(query, options)

        rect = view_to_touch['rect']
        x = rect['x'] + (rect['width'] * (options[:at][:x] / 100.0)).to_i
        y = rect['y'] + (rect['height'] * (options[:at][:y] / 100.0)).to_i

        offset = coordinate(x, y)

        uia_serialize_and_call(:tapOffset, offset, options)

        Calabash::QueryResult.create([view_to_touch], query)
      end

      # @!visibility private
      def _double_tap(query, options={})
        view_to_touch = _gesture_waiter.wait_for_view(query, options)

        rect = view_to_touch['rect']
        x = rect['x'] + (rect['width'] * (options[:at][:x] / 100.0)).to_i
        y = rect['y'] + (rect['height'] * (options[:at][:y] / 100.0)).to_i

        offset = coordinate(x, y)

        uia_serialize_and_call(:doubleTapOffset, offset, options)

        Calabash::QueryResult.create([view_to_touch], query)
      end

      # @!visibility private
      def _long_press(query, options={})

        begin
          _expect_valid_duration(options)
        rescue ArgumentError => e
          raise ArgumentError e
        end

        view_to_touch = _gesture_waiter.wait_for_view(query, options)

        rect = view_to_touch['rect']
        x = rect['x'] + (rect['width'] * (options[:at][:x] / 100.0)).to_i
        y = rect['y'] + (rect['height'] * (options[:at][:y] / 100.0)).to_i

        offset = coordinate(x, y)

        uia_serialize_and_call(:touchHoldOffset, options[:duration], offset)

        Calabash::QueryResult.create([view_to_touch], query)
      end

      # @!visibility private
      def _pan_between(query_from, query_to, options={})

        begin
          _expect_valid_duration(options)
        rescue ArgumentError => e
          raise ArgumentError e
        end

        from_view = _gesture_waiter.wait_for_view(query_from, options)
        to_view = _gesture_waiter.wait_for_view(query_to, options)

        from_offset = uia_center_of_view(from_view)
        to_offset = uia_center_of_view(to_view)

        uia_serialize_and_call(:panOffset, from_offset, to_offset, options)

        {
          :from => Calabash::QueryResult.create([from_view], query_from),
          :to => Calabash::QueryResult.create([to_view], query_to)
        }
      end

      # @!visibility private
      # @todo The default to and from for the pan_* methods are not good for iOS.
      #
      # * from: {x: 90, y: 50}
      # *   to: {x: 10, y: 50}
      #
      # If the view has a UINavigationBar or UITabBar, the defaults *might*
      # cause vertical gestures to start and/or end on one of these bars.
      def _pan(query, from, to, options={})

        begin
          _expect_valid_duration(options)
        rescue ArgumentError => e
          raise ArgumentError, e
        end

        gesture_waiter = _gesture_waiter
        view_to_pan = gesture_waiter.wait_for_view(query, options)

        begin
          check_for_broken_uia_automation(query, view_to_pan, gesture_waiter)
        rescue => e
          raise "Could not pan with query: #{query}\n#{e.message}"
        end

        rect = view_to_pan['rect']

        from_x = rect['width'] * (from[:x]/100.0)
        from_y = rect['height'] * (from[:y]/100.0)
        from_offset = coordinate(from_x, from_y)

        to_x = rect['width'] * (to[:x]/100.0)
        to_y = rect['height'] * (to[:y]/100.0)
        to_offset = coordinate(to_x, to_y)

        uia_serialize_and_call(:panOffset, from_offset, to_offset)

        Calabash::QueryResult.create([view_to_pan], query)
      end

      # @!visibility private
      def pan_screen(view_to_pan, from_offset, to_offset, options)
        begin
          _expect_valid_duration(options)
        rescue ArgumentError => e
          raise ArgumentError, e
        end

        uia_serialize_and_call(:panOffset, from_offset, to_offset, options)

        Calabash::QueryResult.create([view_to_pan], '*')
      end

      # @!visibility private
      # @todo The default to and from for the screen_* methods are not good for iOS.
      #
      # * from: {x: 90, y: 50}
      # *   to: {x: 10, y: 50}
      #
      # If the view has a UINavigationBar or UITabBar, the defaults *might*
      # cause vertical gestures to start and/or end on one of these bars.
      def _flick(query, to, from, options)
        begin
          _expect_valid_duration(options)
        rescue ArgumentError => e
          raise ArgumentError, e
        end

        gesture_waiter = _gesture_waiter
        view_to_pan = gesture_waiter.wait_for_view(query, options)

        begin
          check_for_broken_uia_automation(query, view_to_pan, gesture_waiter)
        rescue => e
          raise "Could not flick with query: #{query}\n#{e.message}"
        end

        rect = view_to_pan['rect']

        from_x = rect['width'] * (from[:x]/100.0)
        from_y = rect['height'] * (from[:y]/100.0)
        from_offset = percent(from_x, from_y)

        to_x = rect['width'] * (to[:x]/100.0)
        to_y = rect['height'] * (to[:y]/100.0)
        to_offset = percent(to_x, to_y)

        uia_serialize_and_call(:flickOffset, from_offset, to_offset, options)

        Calabash::QueryResult.create([view_to_pan], query)
      end

      # @!visibility private
      def flick_screen(view_to_pan, from_offset, to_offset, options)
        begin
          _expect_valid_duration(options)
        rescue ArgumentError => e
          raise ArgumentError, e
        end

        uia_serialize_and_call(:flickOffset, from_offset, to_offset, options)

        Calabash::QueryResult.create([view_to_pan], '*')
      end

      private

      # @!visibility private
      #
      # Unlike the Calabash Android server, the iOS server does not wait
      # before gestures, so the client must do the waiting.  The _gesture_waiter
      # allows access to query, wait, etc. without having to include all of
      # Calabash in this module.
      #
      # @todo Replace with waiting on the iOS Server
      def _gesture_waiter
        lambda do |reference_to_self|
          Class.new do
            # world_for_device will return a copy of the module Calabash::IOS,
            # which has redefined Calabash.default_device to reference this
            # device. We should not keep a reference to gesture_waiter
            # because of this, as the user might change a constant or class
            # variable in Calabash.
            include reference_to_self.send(:world_for_device)

            define_method(:query) do |query, *args|
              reference_to_self.map_route(query, :query, *args)
            end

            def to_s
              '#<Calabash::IOS::GestureWaiter>'
            end

            def inspect
              to_s
            end
          end.new
        end.call(self)
      end

      # @!visibility private
      def _expect_valid_duration(options)
        duration = options[:duration].to_f
        if duration < 0.5 || duration > 60
          message = [
                "Expected :duration 0.5 <= '#{duration}' <= 60",
                'On iOS, gesture durations must be between 0.5 and 60 seconds.',
                'This is a limitation enforced by the UIAutomation API.'
          ].join("\n")
          raise ArgumentError, message
        end
      end
    end
  end
end
