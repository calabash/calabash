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
        view_to_touch = _gesture_waiter.wait_for_view(query, timeout: options[:timeout])

        rect = view_to_touch['rect']
        x = rect['x'] + (rect['width'] * (options[:at][:x] / 100.0)).to_i
        y = rect['y'] + (rect['height'] * (options[:at][:y] / 100.0)).to_i

        @automator.touch({coordinates: coordinate(x, y)})

        Calabash::QueryResult.create([view_to_touch], query)
      end

      # @!visibility private
      def _double_tap(query, options={})
        view_to_touch = _gesture_waiter.wait_for_view(query, timeout: options[:timeout])

        rect = view_to_touch['rect']
        x = rect['x'] + (rect['width'] * (options[:at][:x] / 100.0)).to_i
        y = rect['y'] + (rect['height'] * (options[:at][:y] / 100.0)).to_i

        @automator.double_tap({coordinates: coordinate(x, y)})

        Calabash::QueryResult.create([view_to_touch], query)
      end

      # @!visibility private
      def _long_press(query, options={})
        options[:duration] += 0.2

        begin
          _expect_valid_duration(options)
        rescue ArgumentError => e
          raise ArgumentError e
        end

        view_to_touch = _gesture_waiter.wait_for_view(query, timeout: options[:timeout])

        rect = view_to_touch['rect']
        x = rect['x'] + (rect['width'] * (options[:at][:x] / 100.0)).to_i
        y = rect['y'] + (rect['height'] * (options[:at][:y] / 100.0)).to_i

        @automator.touch_hold({coordinates: coordinate(x, y), duration: options[:duration]})

        Calabash::QueryResult.create([view_to_touch], query)
      end

      def parse_swipe_between_args(query_from, query_to, options)
        from_query_result = nil
        to_query_result  = nil
        from = coordinate(0, 0)
        to = coordinate(0, 0)

        unless query_from.nil?
          from_view = _gesture_waiter.wait_for_view(query_from, timeout: options[:timeout])
          from = coordinate(from_view['rect']['center_x'], from_view['rect']['center_y'])
          from_query_result = Calabash::QueryResult.create([from_view], query_from)
        end

        unless query_to.nil?
          to_view = _gesture_waiter.wait_for_view(query_to, timeout: options[:timeout])
          to = coordinate(to_view['rect']['center_x'], to_view['rect']['center_y'])
          Calabash::QueryResult.create([to_view], query_to)
        end

        offset = options[:offset]

        if offset
          from_offset = offset[:from]

          if from_offset
            x, y = from_offset[:x], from_offset[:y]

            from[:x] += x || 0
            from[:y] += y || 0
          end

          to_offset = offset[:to]

          if from_offset
            x, y = to_offset[:x], to_offset[:y]

            to[:x] += x || 0
            to[:y] += y || 0
          end
        end

        [from, to, options, from_query_result, to_query_result]
      end

      # @!visibility private
      def _pan_between(query_from, query_to, options={})
        from, to, options, from_query_result, to_query_result =
            parse_swipe_between_args(query_from, query_to, options)

        @automator.pan({coordinates:
                            {from: from,
                             to: to},
                        duration: options[:duration]})

        {
          :from => from_query_result,
          :to => to_query_result
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
        gesture_waiter = _gesture_waiter
        view_to_pan = gesture_waiter.wait_for_view(query, timeout: options[:timeout])

        rect = view_to_pan['rect']

        from_x = rect['width'] * (from[:x]/100.0)
        from_y = rect['height'] * (from[:y]/100.0)

        to_x = rect['width'] * (to[:x]/100.0)
        to_y = rect['height'] * (to[:y]/100.0)

        @automator.pan({coordinates: {from: coordinate(from_x, from_y), to: coordinate(to_x, to_y)},
                               duration: options[:duration]})


        Calabash::QueryResult.create([view_to_pan], query)
      end

      # @!visibility private
      # @todo The default to and from for the screen_* methods are not good for iOS.
      #
      # * from: {x: 90, y: 50}
      # *   to: {x: 10, y: 50}
      #
      # If the view has a UINavigationBar or UITabBar, the defaults *might*
      # cause vertical gestures to start and/or end on one of these bars.
      def _flick(query, from, to, options)
        gesture_waiter = _gesture_waiter
        view_to_pan = gesture_waiter.wait_for_view(query, timeout: options[:timeout])

        rect = view_to_pan['rect']

        from_x = rect['width'] * (from[:x]/100.0)
        from_y = rect['height'] * (from[:y]/100.0)

        to_x = rect['width'] * (to[:x]/100.0)
        to_y = rect['height'] * (to[:y]/100.0)

        @automator.flick({coordinates: {from: coordinate(from_x, from_y), to: coordinate(to_x, to_y)},
                        duration: options[:duration]})


        Calabash::QueryResult.create([view_to_pan], query)
      end

      # @!visibility private
      def _flick_between(query_from, query_to, options={})
        from, to, options, from_query_result, to_query_result =
            parse_swipe_between_args(query_from, query_to, options)

        @automator.flick({coordinates:
                            {from: from,
                             to: to},
                        duration: options[:duration]})

        {
            :from => from_query_result,
            :to => to_query_result
        }
      end

      # @!visibility private
      # @todo The pinch gestures are incredibly coarse grained.
      #
      # https://github.com/krukow/calabash-script/commit/fa33550ac7ac4f37da649498becef441d2284cd8
      def _pinch(direction, query, options={})
        gesture_waiter = _gesture_waiter

        view_to_pinch = gesture_waiter.wait_for_view(query, timeout: options[:timeout])

        gesture_options = {
            coordinates: {
                x: view_to_pinch['rect']['center_x'],
                y: view_to_pinch['rect']['center_y'],
            },
            pinch_direction: direction.to_s,
            amount: 50,
            duration: options[:duration]
        }

        @automator.pinch(gesture_options)

        Calabash::QueryResult.create([view_to_pinch], query)
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
