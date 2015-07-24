module Calabash
  module IOS
    # @!visibility private
    module GesturesMixin

      # @todo Extract offset from options
      # @todo Needs unit tests.
      def _tap(query, options={})
        # 1. Find the view to touch
        view_to_touch = gesture_waiter.wait_for_view(query, options)

        # 2. Find the center of view.
        offset = uia_center_of_view(view_to_touch)

        # 3. Serialize the command and call the uia route.
        uia_serialize_and_call(:tapOffset, offset)

        # 4. Return the view found by query - the view that was touched.
        # @todo For review:  Should gestures return views?
        Calabash::QueryResult.create([view_to_touch], query)
      end

      def _double_tap(query, options={})
        view_to_touch = gesture_waiter.wait_for_view(query, options)

        offset = uia_center_of_view(view_to_touch)

        uia_serialize_and_call(:doubleTapOffset, offset)

        Calabash::QueryResult.create([view_to_touch], query)
      end

      def _long_press(query, options={})
        view_to_touch = gesture_waiter.wait_for_view(query, options)

        offset = uia_center_of_view(view_to_touch)

        uia_serialize_and_call(:touchHoldOffset, options[:duration], offset)

        Calabash::QueryResult.create([view_to_touch], query)
      end

      def _pan_between(query_from, query_to, options={})
        from_view = gesture_waiter.wait_for_view(query_from)
        to_view = gesture_waiter.wait_for_view(query_to)

        from_offset = uia_center_of_view(from_view)
        to_offset = uia_center_of_view(to_view)

        uia_serialize_and_call(:panOffset, from_offset, to_offset)

        {
          :from => Calabash::QueryResult.create([from_view], query_from),
          :to => Calabash::QueryResult.create([to_view], query_to)
        }
      end

      private

      # Unlike the Calabash Android server, the iOS server does not wait
      # before gestures.  We need to do this in the client for now.
      # @todo Replace with waiting on the iOS Server
      def gesture_waiter
        @gesture_waiter ||= lambda do |reference_to_self|
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
