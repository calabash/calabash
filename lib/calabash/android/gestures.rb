module Calabash
  module Android
    module Gestures
      # @!visibility private
      def _pan_screen_up(options={})
        from = {x: 50, y: 90}
        to = {x: 50, y: 10}

        pan("* id:'content'", from, to, options)
      end

      # @!visibility private
      def _pan_screen_down(options={})
        from = {x: 50, y: 10}
        to = {x: 50, y: 90}

        pan("* id:'content'", from, to, options)
      end

      # @!visibility private
      def _flick_screen_up(options={})
        from = {x: 50, y: 90}
        to = {x: 50, y: 10}

        flick("* id:'content'", from, to, options)
      end

      # @!visibility private
      def _flick_screen_down(options={})
        from = {x: 50, y: 10}
        to = {x: 50, y: 90}

        flick("* id:'content'", from, to, options)
      end
    end
  end
end
