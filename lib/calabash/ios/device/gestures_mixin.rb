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

      def _tap(query, options={})
        view_to_touch = _gesture_waiter.wait_for_view(query, options)

        offset = uia_center_of_view(view_to_touch)

        uia_serialize_and_call(:tapOffset, offset, options)

        Calabash::QueryResult.create([view_to_touch], query)
      end

      def _double_tap(query, options={})
        view_to_touch = _gesture_waiter.wait_for_view(query, options)

        offset = uia_center_of_view(view_to_touch)

        uia_serialize_and_call(:doubleTapOffset, offset, options)

        Calabash::QueryResult.create([view_to_touch], query)
      end

      def _long_press(query, options={})

        begin
          _expect_valid_duration(options)
        rescue ArgumentError => e
          raise ArgumentError e
        end

        view_to_touch = _gesture_waiter.wait_for_view(query, options)

        offset = uia_center_of_view(view_to_touch)

        uia_serialize_and_call(:touchHoldOffset, options[:duration], offset)

        Calabash::QueryResult.create([view_to_touch], query)
      end

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

      # The default to and from for the pan_* methods are not good for iOS.
      #
      # * from: {x: 90, y: 50}
      # *   to: {x: 10, y: 50}
      #
      # If the view has a UINavigationBar or UITabBar, the defaults will
      # cause vertical gestures to start and/or end on one of these bars.
      #
      # dragInsideWithOptions broke in iOS 7, so the condition should really be
      # `Device.default.simulator? && !Device.ios6?`, but I haven't checked on
      # iOS 9 yet, so I will leave the condition out.
      def _pan(query, from, to, options={})

        begin
          _expect_valid_duration(options)
        rescue ArgumentError => e
          raise ArgumentError e
        end

        gesture_waiter = _gesture_waiter
        view_to_pan = gesture_waiter.wait_for_view(query, options)

        if Device.default.simulator?

          should_raise = false

          content_offset = gesture_waiter.query(query, :contentOffset).first

          if content_offset != '*****'
            # Panning on anything with a content offset is broken.
            should_raise = true
          elsif view_to_pan['class'][/TableViewCell/, 0]
            should_raise = true
          else
            new_query = "#{query} parent UITableViewCell"
            should_raise = !gesture_waiter.query(new_query).empty?
            # TODO: Identify other conditions
            # TODO: Can we detect UITableViewCells?
            # The gist is that if the view is a UIScrollView or in a UIScrollView
            # dragInsideWithOptions does not work
          end

          if should_raise
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
            raise message
          end
        end

        rect = view_to_pan['rect']

        from_x = rect['width'] * (from[:x]/100.0)
        from_y = rect['height'] * (from[:y]/100.0)
        from_offset = percent(from_x, from_y)

        to_x = rect['width'] * (to[:x]/100.0)
        to_y = rect['height'] * (to[:y]/100.0)
        to_offset = percent(to_x, to_y)

        uia_serialize_and_call(:panOffset, from_offset, to_offset)

        Calabash::QueryResult.create([view_to_pan], query)
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
