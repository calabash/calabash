module Calabash
  # Methods for performing gestures.  Gestures are taps, flicks,
  # and pans.
  #
  # Many gestures take an optional :duration. On iOS, the duration must be
  # between 0.5 and 60 (seconds).  This is a limitation of the UIAutomation API.
  module Gestures

    # How long do we wait for a view to appear by default when performing a
    # gesture.
    DEFAULT_GESTURE_WAIT_TIMEOUT = 3

    # Performs a `tap` on the (first) view that matches `query`.
    #
    # Taps the center of the view by default.
    #
    # @example
    #  .        ├────────────── 400 px ───────────────┤
    #
    #      ┬    ┌─────────────────────────────────────┐
    #      |    │2                                   3│
    #      |    │                 4                   │
    #      |    │                                     │
    #   200 px  │                 1                   │
    #      |    │                                     │
    #      |    │             7     5                 │   6
    #      |    │                                     │
    #      ┴    └─────────────────────────────────────┘
    #
    #   1. tap("* marked:'email'")
    #   2. tap("* marked:'email'", at:  {x: 0, y: 0})
    #   3. tap("* marked:'email'", at:  {x: 100, y: 0})
    #   4. tap("* marked:'email'", offset: {y: -40})
    #   5. tap("* marked:'email'", offset: {x: 20, y: 40})
    #   6. tap("* marked:'email'", at: {x: 100, y: 75}, offset: {x: 80})
    #   7. tap("* marked:'email'", at: {x: 50, y: 100},
    #                              offset: {x: -80, y: -40})
    #
    # @param [String] query A query describing the view to tap.
    # @param [Hash] options Options for modifying the details of the touch.
    # @option options [Hash] :at ({x: 50, y: 50}) The point at which the
    #   gesture originates from.  It is a percentage-based translation using
    #   top-left `(0,0)` as the reference point. This translation is always
    #   applied before any `:offset`.
    # @option options [Hash] :offset ({x: 0, y: 0}) Offset to touch point.
    #   Offset supports an `:x` and `:y` key and causes the touch to be
    #   offset with `(x,y)`.  This offset is always applied _after_ any
    #   translation performed by `:at`.
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    def tap(query, options={})
      Query.ensure_valid_query(query)

      Device.default.tap(Query.new(query), options)
    end

    # Performs a `double_tap` on the (first) view that matches `query`.
    # @see tap
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    def double_tap(query, options={})
      Query.ensure_valid_query(query)

      Device.default.double_tap(Query.new(query), options)
    end

    # Performs a `long_press` on the (first) view that matches `query`.
    # On iOS this is often referred to as _touch-and-hold_.  On Android this
    # is known variously as _press_, _long-push_, _press-and-hold_, or _hold_.
    #
    # @see tap
    #
    # @param [Hash] options Options for modifying the details of the touch.
    # @option options [Number] :duration (1.0) The amount of time in seconds to
    #  press.  On iOS, the duration must be between 0.5 and 60.
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    # @raise [ArgumentError] iOS: if the `:duration` is not between 0.5 and 60.
    def long_press(query, options={})
      Query.ensure_valid_query(query)

      Device.default.long_press(Query.new(query), options)
    end

    # Performs a `pan` on the (first) view that matches `query`.
    # A pan is a straight line swipe that pauses at the final point
    # before releasing the gesture. This is the general purpose pan method. For
    # standardized pans see `pan_left`, `pan_right`, `pan_up`, and `pan_down`.
    #
    # @example
    #  Consider a pan on a scrollable view.  When the finger is is released,
    #  the velocity of the view is zero.
    #
    # @example
    #  A scrollable view displays the alphabet. Panning left will cause the
    #  view to scroll right.
    #
    #      Before             After
    #   ┌───────────┐  |  ┌───────────┐
    #   │ A B C D E │  |  │ E F G H I │
    #   │           │  |  │           │
    #   │ <───────┤ │  |  │           │
    #   └───────────┘  |  └───────────┘
    #
    # Apple's UIAutomation 'dragInsideWithOptions' is broken on iOS Simulators.
    # Call `pan` on iOS Simulators >= iOS 7.0 will raise an error.  See the
    # iOS Scroll API for alternatives.
    #
    # @see Calabash::IOS::Scroll#scroll
    # @see Calabash::IOS::Scroll#scroll_to_row
    # @see Calabash::IOS::Scroll#scroll_to_row_with_mark
    # @see Calabash::IOS::Scroll#scroll_to_item
    # @see Calabash::IOS::Scroll#scroll_to_item_with_mark
    #
    # @param [String] query A query describing the view to pan inside.
    # @param [Hash] from ({:x, :y}) The point at which the gesture
    #   originates from.
    # @param [Hash] to ({:x, :y}) The point at which the gesture
    #   ends.
    #
    # @param [Hash] options Options for modifying the details of the pan.
    # @option options [Number] :duration (0.5) How many seconds the pan takes
    #   to complete. On iOS, the duration must be between 0.5 and 60.
    #
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    # @raise [ArgumentError] iOS: if the `:duration` is not between 0.5 and 60.
    # @raise [RuntimeError] If called on an iOS Simulator > iOS 7.
    def pan(query, from, to, options={})
      Query.ensure_valid_query(query)

      Device.default.pan(Query.new(query), from, to, options)
    end

    # Performs a `pan` from the center of the first view that matches
    # `query_from` to the center of the first view that matches `query_to`.
    #
    # @example
    #  Panning between two elements.
    #  `pan_between("* id:'first'", "* id:'second'")`
    #
    #
    #      ┌───────────┐
    #      │           │
    #      │     ─     │  id: 'first'
    #      │      \    │
    #      └───────\───┘
    #               \
    #                \
    #                 \
    #                  \
    #                   \
    #                    \
    #                 ┌───\───────┐
    #                 │    \      │
    #   id: 'second'  │     x     │
    #                 │           │
    #                 └───────────┘
    #
    # @option options [Number] :duration (0.5) How many seconds the swipe takes
    #   to complete.
    # @raise [ViewNotFoundError] If the `query_from` returns no results.
    # @raise [ViewNotFoundError] If the `query_to` returns no results.
    # @raise [ArgumentError] If `query_from` is invalid.
    # @raise [ArgumentError] If `query_to` is invalid.
    # @raise [ArgumentError] iOS: if the `:duration` is not between 0.5 and 60.
    def pan_between(query_from, query_to, options={})
      Query.ensure_valid_query(query_from)
      Query.ensure_valid_query(query_to)

      Device.default.pan_between(Query.new(query_from), Query.new(query_to), options)
    end

    # Performs a `pan` heading `left` on the (first) view that matches `query`.
    # @see pan
    def pan_left(query, options={})
      pan(query, {x: 90, y: 50}, {x: 10, y: 50}, options)
    end

    # Performs a `pan` heading `right` on the (first) view that matches
    # `query`.
    # @see pan
    def pan_right(query, options={})
      pan(query, {x: 10, y: 50}, {x: 90, y: 50}, options)
    end

    # Performs a `pan` heading `up` on the (first) view that matches `query`.
    # @see pan
    def pan_up(query, options={})
      pan(query, {x: 50, y: 90}, {x: 50, y: 10}, options)
    end

    # Performs a `pan` heading `down` on the (first) view that matches `query`.
    # @see pan
    def pan_down(query, options={})
      pan(query, {x: 50, y: 10}, {x: 50, y: 90}, options)
    end

    # Performs a `pan` heading `left` on the screen.
    # @see pan_left
    def pan_screen_left(options={})
      pan_left('*', options)
    end

    # Performs a `pan` heading `right` on the screen.
    # @see pan_right
    def pan_screen_right(options={})
      pan_right('*', options)
    end

    # Performs a `pan` heading `up` on the screen.
    # @see pan_up
    def pan_screen_up(options={})
      _pan_screen_up(options)
    end

    # Performs a `pan` heading `down` on the screen.
    # @see pan_down
    def pan_screen_down(options={})
      _pan_screen_down(options)
    end

    # Performs a `flick` on the (first) view that matches `query`.
    # A flick is a straight line swipe that **lifts the finger while
    # the gesture is still in motion**. This will often cause scrollable
    # views to continue moving for some time after the gesture is released.
    # @see pan
    #
    # @example
    #  A scrollable view displays the alphabet. Flicking left will cause the
    #  view to scroll right.
    #
    #       Before             After
    #    ┌───────────┐  |  ┌───────────┐
    #    │ A B C D E │  |  │F G H I J K│
    #    │           │  |  │           │
    #  <·····──────┤ │  |  │           │
    #    └───────────┘  |  └───────────┘
    #
    # @param [String,Hash,Query] query A query describing the view to flick
    #  inside of.
    # @param [Hash] from ({:x, :y}) The point at which the gesture
    #   originates from.
    # @param [Hash] to ({:x, :y}) The point at which the gesture
    #   ends.
    #
    # @param [Hash] options Options for controlling the flick.
    # @options options [Numeric] :duration The duration of the flick. On iOS,
    #   the duration must be between 0.5 and 60.
    #
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    # @raise [ArgumentError] iOS: if the `:duration` is not between 0.5 and 60.
    def flick(query, from, to, options={})
      Query.ensure_valid_query(query)

      Device.default.flick(Query.new(query), from, to, options)
    end

    # Performs a `flick` heading `left` on the (first) view that matches `query`.
    # @see flick
    def flick_left(query, options={})
      flick(query, {x: 90, y: 50}, {x: 10, y: 50}, options)
    end

    # Performs a `flick` heading `right` on the (first) view that matches
    # `query`.
    # @see flick
    def flick_right(query, options={})
      flick(query, {x: 10, y: 50}, {x: 90, y: 50}, options)
    end

    # Performs a `flick` heading `up` on the (first) view that matches `query`.
    # @see flick
    def flick_up(query, options={})
      flick(query, {x: 50, y: 90}, {x: 50, y: 10}, options)
    end

    # Performs a `flick` heading `down` on the (first) view that matches `query`.
    # @see flick
    def flick_down(query, options={})
      flick(query, {x: 50, y: 10}, {x: 50, y: 90}, options)
    end

    # Performs a `flick` heading `left` on the screen.
    # @see flick_left
    def flick_screen_left(options={})
      flick_left('*', options)
    end

    # Performs a `flick` heading `right` on the screen.
    # @see flick_right
    def flick_screen_right(options={})
      flick_right('*', options)
    end

    # Performs a `flick` heading `up` on the screen.
    # @see flick_up
    def flick_screen_up(options={})
      _flick_screen_up(options)
    end

    # Performs a `flick` heading `down` on the screen.
    # @see flick_down
    def flick_screen_down(options={})
      _flick_screen_down(options)
    end

    # Performs a `pinch` outwards.
    def pinch_out(query, options={})
      Device.default.pinch(:out, query, options)
    end

    # Performs a `pinch` inwards.
    def pinch_in(query, options={})
      Device.default.pinch(:in, query, options)
    end

    # Performs a `pinch` outwards on the screen.
    def pinch_screen_out(options={})
      _pinch_screen(:out, options)
    end

    # Performs a `pinch` inwards on the screen.
    def pinch_screen_in(options={})
      _pinch_screen(:in, options)
    end

    # Performs a `pinch` to zoom out.
    def pinch_to_zoom_out(query, options={})
      _pinch_to_zoom(:out, query, options)
    end

    # Performs a `pinch` to zoom in.
    def pinch_to_zoom_in(query, options={})
      _pinch_to_zoom(:in, query, options)
    end

    # Performs a `pinch` to zoom in on the screen.
    def pinch_screen_to_zoom_in(options={})
      _pinch_screen_to_zoom(:in, options)
    end

    # Performs a `pinch` to zoom in on the screen.
    def pinch_screen_to_zoom_out(options={})
      _pinch_screen_to_zoom(:out, options)
    end

    # !@visibility private
    def _pan_screen_up(options={})
      abstract_method!
    end

    # !@visibility private
    def _pan_screen_down(options={})
      abstract_method!
    end

    # !@visibility private
    def _flick_screen_up(options={})
      abstract_method!
    end

    # !@visibility private
    def _flick_screen_down(options={})
      abstract_method!
    end

    # !@visibility private
    def _pinch_screen(direction, options={})
      abstract_method!
    end

    # !@visibility private
    def _pinch_to_zoom(direction, query, options={})
      abstract_method!
    end

    # !@visibility private
    def _pinch_screen_to_zoom(direction, options={})
      abstract_method!
    end
  end
end
