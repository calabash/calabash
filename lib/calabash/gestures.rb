module Calabash
  # Methods for performing gestures.  Gestures are taps, flicks, and pans.
  # All gestures execute "physical gestures" like human users would.
  #
  # @note All gestures have _undefined return values._  This is intentional.
  #  Please do not rely on return values of gestures in your tests.  For
  #  convenience when working in the console, some gestures return sensible
  #  values.  However, these values are subject to change.
  module Gestures

    # How long do we wait for a view to appear by default when performing a
    # gesture.
    DEFAULT_GESTURE_WAIT_TIMEOUT = 3

    # Performs a **tap** on the first view that matches `query`.
    #
    # Taps the center of the view by default.
    #
    # @example
    #  .        ├────────────── 400 px ───────────────┤
    #
    #      ┬    ┌─────────────────────────────────────┐
    #      |    │2                                   3│
    #      |    │                                     │
    #      |    │                                     │
    #   200 px  │                 1                   │
    #      |    │                                     │
    #      |    │                                     │
    #      |    │                 4                   │
    #      ┴    └─────────────────────────────────────┘
    #
    #   1. cal.tap("* marked:'email'")
    #   2. cal.tap("* marked:'email'", at: {x: 0, y: 0})
    #   3. cal.tap("* marked:'email'", at: {x: 100, y: 0})
    #   4. cal.tap("* marked:'email'", at: {x: 50, y: 100})
    #
    # @param [String, Hash, Calabash::Query] query A query describing the view
    #   to tap.
    # @param [Hash] at (default: `{x: 50, y: 50}`) The point at which the
    #   gesture originates from.  It is a percentage-based translation using
    #   top-left `{x: 0, y: 0}` as the reference point.
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    def tap(query, at: nil)
      Query.ensure_valid_query(query)

      options = {at: at || {x: 50, y: 50}}

      Calabash::Internal.with_default_device {|device| device.tap(Query.new(query), options)}
    end

    # Performs a **double_tap** on the first view that matches `query`.
    #
    # @see #tap
    #
    # @param [String, Hash, Calabash::Query] query A query describing the view
    #  to tap.
    # @param [Hash] at (default: `{x: 50, y: 50}`) The point at which the
    #   gesture originates from.  It is a percentage-based translation using
    #   top-left `{x: 0, y: 0}` as the reference point.
    #
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    def double_tap(query, at: nil)
      Query.ensure_valid_query(query)

      options = {at: at || {x: 50, y: 50}}

      Calabash::Internal.with_default_device {|device| device.double_tap(Query.new(query), options)}
    end

    # Performs a **long_press** on the first view that matches `query`.
    #
    # On iOS this is often referred to as _touch-and-hold_.  On Android this
    # is known variously as _press_, _long-push_, _press-and-hold_, or _hold_.
    #
    # @see #tap
    #
    # @param [String] query A query describing the view to tap.
    # @param [Number] duration (default: 1.0) The amount of time in seconds to
    #  press.  On iOS, the duration must be between 0.5 and 60.
    # @param [Hash] at (default: `{x: 50, y: 50}`) The point at which the
    #   gesture originates from.  It is a percentage-based translation using
    #   top-left `{x: 0, y: 0}` as the reference point.
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    def long_press(query, duration: nil, at: nil)
      Query.ensure_valid_query(query)

      options = {
          at: at || {x: 50, y: 50},
          duration: duration || 1.0
      }

      Calabash::Internal.with_default_device {|device| device.long_press(Query.new(query), options)}
    end

    # Performs a **pan** inside the first view that matches `query`.
    #
    # A pan is a straight line swipe that pauses at the final point
    # before releasing the gesture. This is the general purpose pan method. For
    # standardized pans see {pan_left}, {pan_right}, {pan_up}, and {pan_down}.
    #
    # @example
    #  # Consider a pan on a scrollable view.  When the finger is is released,
    #  # the velocity of the view is zero.
    #
    # @example
    #  # A scrollable view displays the alphabet. Panning left will cause the
    #  # view to scroll right.
    #
    #  cal.pan("* id:'alphabetView'", cal.pct(80, 80), cal.pct(20, 80))
    #
    #      Before             After
    #   ┌───────────┐  |  ┌───────────┐
    #   │ A B C D E │  |  │ E F G H I │
    #   │           │  |  │           │
    #   │ <───────┤ │  |  │           │
    #   └───────────┘  |  └───────────┘
    #
    #
    # @param [String, Hash, Calabash::Query] query A query describing the view
    #  to pan inside.
    # @param [Hash] from `({:x, :y})` The point at which the gesture
    #   originates from.
    # @param [Hash] to `({:x, :y})` The point at which the gesture
    #   ends.
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    def pan(query, from, to, duration: nil)
      Query.ensure_valid_query(query)

      options = {
          duration: duration || DEFAULT_PAN_OPTIONS[:duration]
      }

      Calabash::Internal.with_default_device {|device| device.pan(Query.new(query), from, to, options)}
    end

    # Performs a **pan** from the center of the first view that matches
    # `query_from` to the center of the first view that matches `query_to`.
    #
    # Also known as **drag and drop**.
    #
    # @example
    #  #Panning between two elements.
    #  cal.pan_between("* id:'first'", "* id:'second'")
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
    # @param [String, Hash, Calabash::Query] query_from A query describing the
    #  view to pan *from*
    # @param [String, Hash, Calabash::Query] query_to A query describing the
    #  view to pan *to*
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    # @raise [ViewNotFoundError] If the `query_from` returns no results.
    # @raise [ViewNotFoundError] If the `query_to` returns no results.
    # @raise [ArgumentError] If `query_from` is invalid.
    # @raise [ArgumentError] If `query_to` is invalid.
    def pan_between(query_from, query_to, duration: nil)
      Query.ensure_valid_query(query_from)
      Query.ensure_valid_query(query_to)

      options = {
          duration: duration || DEFAULT_PAN_OPTIONS[:duration]
      }

      Calabash::Internal.with_default_device do |device|
        device.pan_between(Query.new(query_from), Query.new(query_to), options)
      end
    end

    # Performs a **pan** heading _left_ inside the first view that matches
    # `query`.
    #
    # @see #pan
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    def pan_left(query, duration: nil)
      pan(query, {x: 90, y: 50}, {x: 10, y: 50}, duration: duration)
    end

    # Performs a **pan** heading _right_ inside the first view that matches
    # `query`.
    #
    # @see #pan
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    def pan_right(query, duration: nil)
      pan(query, {x: 10, y: 50}, {x: 90, y: 50}, duration: duration)
    end

    # Performs a **pan** heading _up_ inside the first view that matches
    # `query`.
    #
    # @see #pan
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    def pan_up(query, duration: nil)
      pan(query, {x: 50, y: 90}, {x: 50, y: 10}, duration: duration)
    end

    # Performs a **pan** heading _down_ inside the first view that matches
    # `query`.
    #
    # @see #pan
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    def pan_down(query, duration: nil)
      pan(query, {x: 50, y: 10}, {x: 50, y: 90}, duration: duration)
    end

    # Performs a **pan** heading _left_ on the screen.
    #
    # @see #pan
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    def pan_screen_left(duration: nil)
      options = {
          duration: duration || DEFAULT_PAN_OPTIONS[:duration]
      }

      pan_left('*', options)
    end

    # Performs a **pan** heading _right_ on the screen.
    #
    # @see #pan
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    def pan_screen_right(duration: nil)
      options = {
          duration: duration || DEFAULT_PAN_OPTIONS[:duration]
      }

      pan_right('*', options)
    end

    # Performs a **pan** heading _up_ on the screen.
    #
    # @see #pan
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    def pan_screen_up(duration: nil)
      options = {
          duration: duration || DEFAULT_PAN_OPTIONS[:duration]
      }

      _pan_screen_up(options)
    end

    # Performs a **pan** heading _down_ on the screen.
    #
    # @see #pan
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    def pan_screen_down(duration: nil)
      options = {
          duration: duration || DEFAULT_PAN_OPTIONS[:duration]
      }

      _pan_screen_down(options)
    end

    # Performs a **flick** inside the first view that matches `query`.
    #
    # A flick is a straight line swipe that **lifts the finger while
    # the gesture is still in motion**. This will often cause scrollable
    # views to continue moving for some time after the gesture is released.
    #
    # It is likely that the gesture you want to automate is a {pan}, not a
    # flick.
    #
    # @see pan
    #
    # @example
    #  # A scrollable view displays the alphabet. Flicking left will cause the
    #  # view to scroll right.
    #
    #  cal.flick("* id:'alphabetView'", cal.pct(80, 80), cal.pct(20, 80))
    #
    #       Before             After
    #    ┌───────────┐  |  ┌───────────┐
    #    │ A B C D E │  |  │F G H I J K│
    #    │           │  |  │           │
    #  <·····──────┤ │  |  │           │
    #    └───────────┘  |  └───────────┘
    #
    # @param [String,Hash,Query] query A query describing the view to flick
    #  inside.
    # @param [Hash] from `({:x, :y})` The point at which the gesture
    #   originates from.
    # @param [Hash] to `({:x, :y})` The point at which the gesture
    #   ends.
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    def flick(query, from, to, duration: nil)
      Query.ensure_valid_query(query)

      options = {
          duration: duration || DEFAULT_PAN_OPTIONS[:duration]
      }

      Calabash::Internal.with_default_device do |device|
        device.flick(Query.new(query), from, to, options)
      end
    end

    # Performs a **flick** heading _left_ inside the first view that matches
    # `query`.
    # @see #flick
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    def flick_left(query, duration: nil)
      flick(query, {x: 90, y: 50}, {x: 10, y: 50}, duration: duration)
    end

    # Performs a **flick** heading _right_ inside the first view that matches
    # `query`.
    # @see #flick
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    def flick_right(query, duration: nil)
      flick(query, {x: 10, y: 50}, {x: 90, y: 50}, duration: duration)
    end

    # Performs a **flick** heading _up_ inside the first view that matches
    # `query`.
    # @see #flick
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    def flick_up(query, duration: nil)
      flick(query, {x: 50, y: 90}, {x: 50, y: 10}, duration: duration)
    end

    # Performs a **flick** heading _down_ inside the first view that matches
    # `query`.
    # @see #flick
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    def flick_down(query, duration: nil)
      flick(query, {x: 50, y: 10}, {x: 50, y: 90}, duration: duration)
    end

    # Performs a **flick** heading _left_ on the screen.
    # @see #flick
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    def flick_screen_left(duration: nil)
      options = {
          duration: duration || DEFAULT_PAN_OPTIONS[:duration]
      }

      flick_left('*', options)
    end

    # Performs a **flick** heading _right_ on the screen.
    # @see #flick
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    def flick_screen_right(duration: nil)
      options = {
          duration: duration || DEFAULT_PAN_OPTIONS[:duration]
      }

      flick_right('*', options)
    end

    # Performs a **flick** heading _up_ on the screen.
    # @see #flick
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    def flick_screen_up(duration: nil)
      options = {
          duration: duration || DEFAULT_PAN_OPTIONS[:duration]
      }

      _flick_screen_up(options)
    end

    # Performs a **flick** heading _down_ on the screen.
    # @see #flick
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    def flick_screen_down(duration: nil)
      options = {
          duration: duration || DEFAULT_PAN_OPTIONS[:duration]
      }

      _flick_screen_down(options)
    end

    # Performs a **pinch** outwards inside the first view match by `query`.
    #
    # The gestures will be similar to two fingers pressing down near the
    # center of the view and simultaneously moving towards the opposite corners
    # of the view
    #
    # @example
    #  # We have a webview that we want to pinch out on
    #
    #  cal.pinch_out("* id:'webView'")
    #
    #         Application
    #  ┌───────────────────────┐
    #  │───────────────────────│
    #  │      id: webview      │
    #  │  ┌─────────────────┐  │
    #  │  │  ^              │  │
    #  │  │   \             │  │
    #  │  │    \            │  │
    #  │  │     *    *      │  │
    #  │  │           \     │  │
    #  │  │            \    │  │
    #  │  │             v   │  │
    #  │  └─────────────────┘  │
    #  └───────────────────────┘
    #
    # @example
    #  # We have a MapView rendering a map. We want to zoom it in.
    #  # On iOS, we should pinch out to zoom in
    #  # On Android, we should pinch in to zoom in.
    #
    #  if cal.android?
    #    cal.pinch_in({class: "MapView"})
    #  elsif cal.ios?
    #    cal.pinch_out({class: "MapView"})
    #  end
    #
    # @param [String, Hash, Calabash::Query] query A query describing the view
    #   to pinch.
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    def pinch_out(query, duration: nil)
      options = {
          duration: duration || DEFAULT_PAN_OPTIONS[:duration]
      }

      Calabash::Internal.with_default_device {|device| device.pinch(:out, query, options)}
    end

    # Performs a **pinch** inwards inside the first view match by `query`.
    #
    # The gestures will be similar to two fingers pressing down in the opposite
    # corners of the view  and simultaneously moving towards the center of the
    # view.
    #
    # @example
    #  # We have a webview that we want to pinch in on
    #
    #  cal.pinch_in("* id:'webView'")
    #
    #         Application
    #  ┌───────────────────────┐
    #  │───────────────────────│
    #  │      id: webview      │
    #  │  ┌─────────────────┐  │
    #  │  │  *              │  │
    #  │  │   \             │  │
    #  │  │    \            │  │
    #  │  │     v    ^      │  │
    #  │  │           \     │  │
    #  │  │            \    │  │
    #  │  │             *   │  │
    #  │  └─────────────────┘  │
    #  └───────────────────────┘
    #
    # @example
    #  # We have a MapView rendering a map. We want to zoom it in.
    #  # On iOS, we should pinch out to zoom in
    #  # On Android, we should pinch in to zoom in.
    #
    #  if cal.android?
    #    cal.pinch_in({class: "MapView"})
    #  elsif cal.ios?
    #    cal.pinch_out({class: "MapView"})
    #  end
    #
    # @param [String, Hash, Calabash::Query] query A query describing the view
    #   to pinch.
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    def pinch_in(query, duration: nil)
      options = {
          duration: duration || DEFAULT_PAN_OPTIONS[:duration]
      }

      Calabash::Internal.with_default_device {|device| device.pinch(:in, query, options)}
    end

    # Performs a **pinch** outwards on the screen.
    #
    # @see #pinch_out
    #
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    def pinch_screen_out(duration: nil)
      options = {
          duration: duration || DEFAULT_PAN_OPTIONS[:duration]
      }

      _pinch_screen(:out, options)
    end

    # Performs a **pinch** inwards on the screen.
    #
    # @see #pinch_in
    #
    # @param [Number] duration (default: 1.0) The amount of time in seconds the
    #  gesture lasts.
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    def pinch_screen_in(duration: nil)
      options = {
          duration: duration || DEFAULT_PAN_OPTIONS[:duration]
      }

      _pinch_screen(:in, options)
    end

    # Performs a **pinch** to zoom out.
    #
    # @param [String, Hash, Calabash::Query] query A query describing the view
    #   to pinch.
    # @param [Hash] options Options for controlling the pinch.
    # @option options [Numeric] :duration The duration of the pinch. On iOS,
    #   the duration must be between 0.5 and 60.
    #
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    # @raise [ArgumentError] iOS: if the `:duration` is not between 0.5 and 60.
    def pinch_to_zoom_out(query, options={})
      _pinch_to_zoom(:out, query, options)
    end

    # Performs a **pinch** to zoom in.
    #
    # @param [String, Hash, Calabash::Query] query A query describing the view
    #   to pinch.
    # @param [Hash] options Options for controlling the pinch.
    # @option options [Numeric] :duration The duration of the pinch. On iOS,
    #   the duration must be between 0.5 and 60.
    #
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    # @raise [ArgumentError] iOS: if the `:duration` is not between 0.5 and 60.
    def pinch_to_zoom_in(query, options={})
      _pinch_to_zoom(:in, query, options)
    end

    # Performs a **pinch** on the screen to zoom in.
    #
    # @param [Hash] options Options for controlling the pinch.
    # @option options [Numeric] :duration The duration of the pinch. On iOS,
    #   the duration must be between 0.5 and 60.
    #
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    # @raise [ArgumentError] iOS: if the `:duration` is not between 0.5 and 60.
    def pinch_screen_to_zoom_in(options={})
      _pinch_screen_to_zoom(:in, options)
    end

    # Performs a **pinch** on the screen to zoom out.
    #
    # @param [Hash] options Options for controlling the pinch.
    # @option options [Numeric] :duration The duration of the pinch. On iOS,
    #   the duration must be between 0.5 and 60.
    #
    # @raise [ViewNotFoundError] If the `query` returns no results.
    # @raise [ArgumentError] If `query` is invalid.
    # @raise [ArgumentError] iOS: if the `:duration` is not between 0.5 and 60.
    def pinch_screen_to_zoom_out(options={})
      _pinch_screen_to_zoom(:out, options)
    end

    # @!visibility private
    define_method(:_pan_screen_up) do |options={}|
      abstract_method!(:_pan_screen_up)
    end

    # @!visibility private
    define_method(:_pan_screen_down) do |options={}|
      abstract_method!(:_pan_screen_down)
    end

    # @!visibility private
    define_method(:_flick_screen_up) do |options={}|
      abstract_method!(:_flick_screen_up)
    end

    # @!visibility private
    define_method(:_flick_screen_down) do |options={}|
      abstract_method!(:_flick_screen_down)
    end

    # @!visibility private
    DEFAULT_PAN_OPTIONS = {duration: 1}
  end
end
