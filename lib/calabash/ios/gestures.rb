module Calabash
  module IOS

    # @!visibility private
    module Gestures
      # @!visibility private
      define_method (:_swipe_coordinates_for_screen) do
        points_from_top = gesture_points_from_top
        points_from_bottom = gesture_points_from_bottom

        top_view = query('*').first

        height = top_view['frame']['height'].to_f
        width = top_view['frame']['width'].to_f

        start_y = height - points_from_bottom
        end_y = points_from_top
        x = width/2.0

        {bottom: coordinate(x, start_y), top: coordinate(x, end_y)}
      end

      # @!visibility private
      # Concrete implementation of pan_screen_up gesture.
      define_method (:_pan_screen_up) do |options={}|
        swipe = _swipe_coordinates_for_screen
        gesture_options = options.merge({offset: {from: swipe[:bottom], to: swipe[:top]}})

        Device.default.pan_between(nil, nil, gesture_options)
      end

      # @!visibility private
      # Concrete implementation of pan_screen_down gesture.
      define_method (:_pan_screen_down) do |options={}|
        swipe = _swipe_coordinates_for_screen
        gesture_options = options.merge({offset: {from: swipe[:top], to: swipe[:bottom]}})

        Device.default.pan_between(nil, nil, gesture_options)
      end

      # @!visibility private
      # Concrete implementation of flick_screen_up gesture.
      define_method (:_flick_screen_up) do |options={}|
        swipe = _swipe_coordinates_for_screen
        gesture_options = options.merge({offset: {from: swipe[:bottom], to: swipe[:top]}})

        Device.default.flick_between(nil, nil, gesture_options)
      end

      # @!visibility private
      # Concrete implementation of flick_screen_down gesture.
      define_method (:_flick_screen_down) do |options={}|
        swipe = _swipe_coordinates_for_screen
        gesture_options = options.merge({offset: {from: swipe[:top], to: swipe[:bottom]}})

        Device.default.flick_between(nil, nil, gesture_options)
      end

      # @!visibility private
      # Concrete implementation of pinch_screen
      define_method (:_pinch_screen) do |direction, options={}|
        Device.default.pinch(direction, '*', options)
      end

      # @!visibility private
      # Concrete implementation of pinch_to_zoom
      define_method (:_pinch_to_zoom) do |direction, query, options={}|
        gesture_direction = direction == :in ? :out : :in
        Device.default.pinch(gesture_direction, query, options)
      end

      # @!visibility private
      # Concrete implementation of pinch_screen_to_zoom
      define_method (:_pinch_screen_to_zoom) do |direction, options={}|
        gesture_direction = direction == :in ? :out : :in
        Device.default.pinch(gesture_direction, '*', options)
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
