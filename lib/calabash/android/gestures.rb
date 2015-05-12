module Calabash
  module Android
    module Gestures
      # @!visibility private
      def _pan(query, from, to, options={})
        gesture_options = {}
        gesture_options[:time] = options[:duration]
        gesture_from = {}
        gesture_from[:x] = from[:x]
        gesture_from[:y] = from[:y]
        gesture_from[:offset] = {}
        gesture_to = {}
        gesture_to[:x] = to[:x]
        gesture_to[:y] = to[:y]
        gesture_to[:offset] = {}
        gesture_options[:flick] = options[:flick]

        if gesture_from[:x] == 100
          gesture_from[:offset][:x] = -1
        elsif gesture_from[:x] == 0
          gesture_from[:offset][:x] = 1
        end

        if gesture_from[:y] == 100
          gesture_from[:offset][:y] = -1
        elsif gesture_from[:y] == 0
          gesture_from[:offset][:y] = 1
        end

        if gesture_to[:x] == 100
          gesture_to[:offset][:x] = -1
        elsif gesture_to[:x] == 0
          gesture_to[:offset][:x] = 1
        end

        if gesture_to[:y] == 100
          gesture_to[:offset][:y] = -1
        elsif gesture_to[:y] == 0
          gesture_to[:offset][:y] = 1
        end

        execute_gesture(Gesture.with_parameters(Gesture.generate_swipe(gesture_from, gesture_to, gesture_options), {query_string: query}.merge(gesture_options)))
      end

      def _flick(query, from, to, options={})
        _pan(query, from, to, options.merge({flick: true}))
      end
    end
  end
end