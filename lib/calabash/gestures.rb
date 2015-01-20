module Calabash
  # Methods for performing gestures.  Gestures are taps, flicks,
  # and pans.
  module Gestures

    # Performs a `tap` on the (first) view that matches `query`.
    #
    # Taps the center of the view by default.
    #
    # @example
    #
    #          ├────────────── 400 px ───────────────┤
    #
    #     ┬    ╔═════════════════════════════════════╗
    #     |    ║2                                   3║
    #     |    ║                  4                  ║
    #     |    ║                                     ║
    #  200 px  ║                  1                  ║
    #     |    ║                                     ║
    #     |    ║              7     5                ║   6
    #     |    ║                                     ║
    #     ┴    ╚═════════════════════════════════════╝
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
    # @option options [Hash] at (`{x: 50, y: 50}`) The point at which the
    #   gesture originates from.  It is a percentage-based translation using
    #   top-left `(0,0)` as the reference point. This translation is always
    #   applied before any `:offset`.
    # @option options [Hash] :offset (`{x: 0, y: 0}`) Offset to touch point.
    #   Offset supports an `:x` and `:y` key and causes the touch to be
    #   offset with `(x,y)`.  This offset is always applied _after_ any
    #   translation performed by `:at`.
    # @option options [Number] wait_after (0) How many seconds to wait after
    #   issuing the touch.
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    def tap(query, options={})
      ensure_valid_query(query)

      _tap(query, options)
    end

    # Performs a `double_tap` on the (first) view that matches `query`.
    # @see tap
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    def double_tap(query, options={})
      ensure_valid_query(query)

      _double_tap(query, options)
    end

    # Performs a `long_press` on the (first) view that matches `query`.
    # On iOS this is often referred to as _touch-and-hold_.  On Android this
    # is known variously as _press_, _long-push_, _press-and-hold_, or _hold_.
    #
    # @see tap
    # @param [Hash] options Options for modifying the details of the touch.
    # @option options [Number] :duration (1.0) The amount of time in seconds to
    #  press.
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    def long_press(query, options={})
      ensure_valid_query(query)

      _long_press(query, options)
    end

    # Performs a `pan` on the (first) view that matches `query`.
    # A pan is a straight line swipe that pauses at the final point
    # before releasing the gesture.
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
    #   ╔═══════════╗  |  ╔═══════════╗
    #   ║ A B C D E ║  |  ║ E F G H I ║
    #   ║           ║  |  ║           ║
    #   ║ <───────┤ ║  |  ║           ║
    #   ╚═══════════╝  |  ╚═══════════╝
    #
    # @param [String] query A query describing the view to pan inside.
    # @param [Hash] options Options for modifying the details of the pan.
    #
    # @option options [Hash] at (`{x: 50, y: 50}`) The point at which the gesture
    #   originates from.  It is a percentage-based translation using top-left
    #   `(0,0)` as the reference point.
    # @option options [Number] wait_after (0) How many seconds to wait after
    #   issuing the pan.
    # @option options [Number] duration (0.5) How many seconds the swipe takes
    #   to complete.
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    def pan(query, from, to, options={})
      ensure_valid_query(query)

      _pan(query, from, to, options)
    end

    # Performs a `pan` heading `left` on the (first) view that matches `query`.
    # @see pan
    def pan_left(query, options={})
      pan(query, {x: 100, y: 50}, {x: 0, y: 50}, options)
    end

    # Performs a `pan` heading `right` on the (first) view that matches
    # `query`.
    # @see pan
    def pan_right(query, options={})
      pan(query, {x: 0, y: 50}, {x: 100, y: 50}, options)
    end

    # Performs a `pan` heading `up` on the (first) view that matches `query`.
    # @see pan
    def pan_up(query, options={})
      pan(query, {x: 50, y: 100}, {x: 50, y: 0}, options)
    end

    # Performs a `pan` heading `down` on the (first) view that matches `query`.
    # @see pan
    def pan_down(query, options={})
      pan(query, {x: 50, y: 0}, {x: 50, y: 100}, options)
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
    #    ╔═══════════╗  |  ╔═══════════╗
    #    ║ A B C D E ║  |  ║F G H I J K║
    #    ║           ║  |  ║           ║
    #  <·····──────┤ ║  |  ║           ║
    #    ╚═══════════╝  |  ╚═══════════╝
    #
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    def flick(query, from, to, options={})
      ensure_valid_query(query)

      _flick(query, from, to, options)
    end

    # @!visibility private
    def valid_query?(query)
      query.is_a?(String)
    end

    # @!visibility private
    def ensure_valid_query(query)
      unless valid_query?(query)
        raise ArgumentError, "invalid query '#{query}' (#{query.class})"
      end
    end

    # @!visibility private
    def _tap(query, options={})
      abstract_method!
    end

    # @!visibility private
    def _double_tap(query, options={})
      abstract_method!
    end

    # @!visibility private
    def _long_press(query, options={})
      abstract_method!
    end

    # @!visibility private
    def _pan(query, from, to, options={})
      abstract_method!
    end

    # @!visibility private
    def _flick(query, from, to, options={})
      abstract_method!
    end
  end
end
