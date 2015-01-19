module Calabash
  # Methods for performing gestures.  Gestures are taps, flicks,
  # and pans.
  module Gestures

    # Performs a `tap` on the (first) view that matches query `query`.
    #
    # Taps the center of the view by default.
    #
    # @example
    #
    #         ├────────────── 400 px ───────────────┤
    #
    #    ┬    ╔═════════════════════════════════════╗
    #    |    ║2                                   3║
    #    |    ║                  4                  ║
    #    |    ║                                     ║
    # 200 px  ║                  1                  ║
    #    |    ║                                     ║
    #    |    ║              7     5                ║   6
    #    |    ║                                     ║
    #    ┴    ╚═════════════════════════════════════╝
    #
    #  1. tap("* marked:'email'")
    #  2. tap("* marked:'email'", at:  {x: 0, y: 0})
    #  3. tap("* marked:'email'", at:  {x: 100, y: 0})
    #  4. tap("* marked:'email'", offset: {y: -40})
    #  5. tap("* marked:'email'", offset: {x: 20, y: 40})
    #  6. tap("* marked:'email'", at: {x: 100, y: 75}, offset: {x: 80})
    #  7. tap("* marked:'email'", at: {x: 50, y: 100}, offset: {x: -80, y: -40})
    #
    # @param [String] query A query describing the view to tap.
    # @param [Hash] options Options for modifying the details of the touch.
    # @option [Hash] at (`{x: 50, y: 50}`) The point at which the gesture
    #   originates from.  It is a percentage-based translation using `(0,0)`
    #   as the reference point.  This translation is always applied before
    #   any `:offset`.
    # @option options [Hash] :offset (`{x: 0, y: 0}`) Offset to touch point.
    #   Offset supports an `:x` and `:y` key and causes the touch to be
    #   offset with `(x,y)`.  This offset is always applied _after_ any
    #   translation performed by `:at`.
    # @option [Number] wait_before (0) How many seconds to wait before
    #   issuing the touch after the view is found.
    # @option [Number] wait_after (0) How many seconds to wait after
    #   issuing the touch.
    # @raise [ViewNotFoundError] If the `query` returns no results.
    def tap(query, options={})
      _tap(query, options)
    end

    private

    # @!visibility private
    def _tap(query, options={})
      abstract_method!
    end
  end
end
