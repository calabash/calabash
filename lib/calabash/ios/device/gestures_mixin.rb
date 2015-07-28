module Calabash
  module IOS
    # @!visibility private
    module GesturesMixin

      # @todo Extract offset from options
      # @todo Needs unit tests.
      def _tap(query, options={})
        # 1. Find the view to touch
        view_to_touch = _gesture_waiter.wait_for_view(query, options)

        # 2. Find the center of view.
        offset = uia_center_of_view(view_to_touch)

        # 3. Serialize the command and call the uia route.
        uia_serialize_and_call(:tapOffset, offset)

        # 4. Return the view found by query - the view that was touched.
        # @todo For review:  Should gestures return views?
        Calabash::QueryResult.create([view_to_touch], query)
      end

      def _double_tap(query, options={})
        view_to_touch = _gesture_waiter.wait_for_view(query, options)

        offset = uia_center_of_view(view_to_touch)

        uia_serialize_and_call(:doubleTapOffset, offset)

        Calabash::QueryResult.create([view_to_touch], query)
      end

      def _long_press(query, options={})
        view_to_touch = _gesture_waiter.wait_for_view(query, options)

        offset = uia_center_of_view(view_to_touch)

        uia_serialize_and_call(:touchHoldOffset, options[:duration], offset)

        Calabash::QueryResult.create([view_to_touch], query)
      end

      def _pan_between(query_from, query_to, options={})
        from_view = _gesture_waiter.wait_for_view(query_from)
        to_view = _gesture_waiter.wait_for_view(query_to)

        from_offset = uia_center_of_view(from_view)
        to_offset = uia_center_of_view(to_view)

        uia_serialize_and_call(:panOffset, from_offset, to_offset)

        {
          :from => Calabash::QueryResult.create([from_view], query_from),
          :to => Calabash::QueryResult.create([to_view], query_to)
        }
      end

      def _pan(query, from, to, options={})
        if Device.default.simulator?
          message = [
                "Apple's UIAutomation `dragInsideWithOptions` API is broken for iOS > 7",
                'If you are trying to scroll on a UITableView or UICollectionView, try using the scroll_* methods'
          ]

          raise message.join("\n")
        end

        view_to_pan = _gesture_waiter.wait_for_view(query, options)

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

      # !@visibility private
      # Unlike the Calabash Android server, the iOS server does not wait
      # before gestures.
      # @todo Replace with waiting on the iOS Server
      def _gesture_waiter
        @_gesture_waiter ||= lambda do |reference_to_self|
          Class.new do
            include Calabash::IOS
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
    end
  end
end
