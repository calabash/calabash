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

      private

      # Unlike the Calabash Android server, the iOS server does not wait
      # before gestures.  We need to do this in the client for now.
      # @todo Replace with waiting on the iOS Server
      def gesture_waiter
        @gesture_waiter ||= lambda do |reference_to_self|
          Class.new do
            include Calabash::Wait
            define_method(:query) do |query, *args|
              reference_to_self.map_route(query, :query, *args)
            end
          end.new
        end.call(self)
      end
    end
  end
end
