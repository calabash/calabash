module Calabash
  module IOS

    # @!visibility private
    module Gestures

      # Concrete implementation of pan_screen_up gesture.
      def _pan_screen_up(options={})

        gesture_options = options.dup
        gesture_options[:duration] ||= 0.5
        gesture_options[:timeout] ||= Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT

        points_from_top = gesture_points_from_top
        points_from_bottom = gesture_points_from_bottom

        top_view = query('*').first

        height = top_view['frame']['height'].to_f
        width = top_view['frame']['width'].to_f

        start_y = height - points_from_bottom
        end_y = points_from_top
        x = width/2.0

        from_offset = coordinate(x, start_y)
        to_offset = coordinate(x, end_y)

        Device.default.pan_screen(top_view, from_offset, to_offset, gesture_options)
      end

      # Concrete implementation of pan_screen_down gesture.
      def _pan_screen_down(options={})

        gesture_options = options.dup
        gesture_options[:duration] ||= 0.5
        gesture_options[:timeout] ||= Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT

        points_from_top = gesture_points_from_top
        points_from_bottom = gesture_points_from_bottom

        top_view = query('*').first

        height = top_view['frame']['height'].to_f
        width = top_view['frame']['width'].to_f

        start_y = points_from_top
        end_y = height - points_from_bottom
        x = width/2.0

        from_offset = coordinate(x, start_y)
        to_offset = coordinate(x, end_y)

        Device.default.pan_screen(top_view, from_offset, to_offset, gesture_options)
      end

      private

      # Number of points from the top to start a full-screen vertical gesture.
      def gesture_points_from_top
        # 20 pixels for status bar in portrait; status bar is usually missing
        # in landscape @todo route for status bar height

        # Swiping from top will pull down the notification center.
        # Touching the status bar can cause table views to scroll to the top.
        orientation = status_bar_orientation
        if orientation == 'down' || orientation == 'up'
          points_from_top = 20
        else
          points_from_top = 10
        end

        # Navigation bar will intercept touches.
        result = query('UINavigationBar')
        if !result.empty?
          navbar = result.first
          points_from_top = points_from_top + navbar['frame']['height'] + 10
        end
        points_from_top
      end

      # Number of points from the bottom to start a full-screen vertical gesture.
      def gesture_points_from_bottom
        # Dragging from the bottom will lift the transport controls.
        points_from_bottom = 10

        # Tab bar will intercept touches _and_ its hit box is larger than its
        # visible rect!
        result = query('UITabBar')
        if !result.empty?
          tabbar = result.first
          points_from_bottom = points_from_bottom + tabbar['frame']['height']
        end

        # @todo toolbars might not be anchored to the bottom of the screen

        # Toolbars will intercept touches.
        result = query('UIToolBar')
        if !result.empty?
          toolbar = result.first
          points_from_bottom = points_from_bottom + toolbar['frame']['height']
        end
        points_from_bottom
      end
    end
  end
end
