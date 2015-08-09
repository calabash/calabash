module Calabash
  # Query, flash, backdoor, etc.
  module Interactions
    # Queries the view hierarchy to find all views matching `query`.
    # Optionally query takes a variable number of “invocation” arguments
    # (args below).
    # If called with an empty list of *args, query will find the views
    # specified by `query` and return a QueryResult of serialized views.
    #
    # @note If this method is called with invocation arguments, it might allow
    #  the author of the test to do an interaction with app that a user would
    #  not be able to (for example changing the text of a view).
    #
    # @example
    #  query("* marked:'my view'")
    #  query("* id:'foo' descendant UIButton")
    #  query("android.widget.ProgressBar")
    #  query("* {text CONTAINS 'something'}")
    #  query("* {y > 200}")
    #
    # @example
    #  # Find all the elements, visible as well as invisible
    #  query("all *")
    #
    # @example
    #  query("editText", :setText => 'my text')
    #  query("scrollView", :scrollBy => [50, 10])
    #
    # @example
    #  irb(main):009:0> query("UITabBarButton index:0")
    #  [
    #      [0] {
    #      "class" => "UITabBarButton",
    #      "id" => nil,
    #      "rect" => {
    #          "center_x" => 40,
    #          "y" => 520,
    #          "width" => 76,
    #          "x" => 2,
    #          "center_y" => 544,
    #          "height" => 48
    #      },
    #      "frame" => {
    #          "y" => 1,
    #          "width" => 76,
    #          "x" => 2,
    #          "height" => 48
    #      },
    #      "label" => "Reader",
    #      "description" => "<UITabBarButton: 0xdabb510; frame = (2 1; 76 48); opaque = NO; layer = <CALayer: 0xdabd8e0>>"
    #  }
    #  ]
    #
    # @note Even if the query matches only one view, the QueryResult returned
    #  is still a list of elements.
    #
    # @param [String, Hash, Calabash::Query] query The query to match the
    #  view(s)
    #
    # @param args Optional var-args list describing a chain of method
    #  names (selectors).
    #
    # @return [Calabash::QueryResult] A result of the query
    def query(query, *args)
      Calabash::Device.default.map_route(Query.new(query), :query, *args)
    end

    # Flashes any views matching `query`. Only one view is flashed at a time,
    # in the order they are returned.
    #
    # @param [String, Hash, Calabash::Query] query The query to match the
    #  view(s)
    def flash(query)
      Calabash::Device.default.map_route(Query.new(query), :flash)
    end

    # Evaluate javascript in a Web View. On iOS, an implicit return is
    # inserted, on Android an explicit return is needed.
    #
    # @example
    #  # iOS
    #  evaluate_javascript_in("UIWebView", "2+2")
    #  # Android
    #  evaluate_javascript_in("WebView", "return 2+2")
    #
    # @example
    #  # iOS
    #  evaluate_javascript_in("WKWebView",
    #         "document.body.style.backgroundColor = 'red';")
    #
    #  # Android
    #  evaluate_javascript_in("XWalkContent",
    #         "document.body.style.backgroundColor = 'red';")
    #
    # @note No error will be raised if the javascript given is invalid, or
    #  throws an exception.
    #
    # @param [String, Hash, Calabash::Query] query Query that matches the view
    # @param [String] javascript The javascript to evaluate
    #
    # @raise ViewNotFoundError If no views are found matching `query`
    def evaluate_javascript_in(query, javascript)
      wait_for_view(query,
                    timeout: Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT)

      _evaluate_javascript_in(query, javascript)
    end

    # Invoke a method in your application.
    #
    # This is an escape hatch for calling an arbitrary hook inside
    # (the test build) of your app.  Commonly used to "go around" the UI for
    # speed purposes or reset the app to a good known state.
    #
    # For iOS this method calls a method on the app's AppDelegate object.
    #
    # For Android this method tries to invoke a method on the current Activity
    # instance. If the method is not defined in the current activity, Calabash
    # tries to invoke the method on the current Application instance.
    #
    # @note The Android implementation accepts any number of arguments, of any
    #  type including null (Ruby nil). The iOS implementation does not accept
    #  more than one argument, of the type NSString (Ruby String) or
    #  NSDictionary (Ruby Hash).
    #
    #
    # ### For iOS
    #
    # You must create a method on you app delegate of the form:
    #
    #     - (NSString *) calabashBackdoor:(NSString *)aIgnorable;
    #
    # or if you want to pass parameters
    #
    #     - (NSString *) calabashBackdoor:(NSDictionary *)params;
    #
    # ### For Android
    #
    # You must create a public method in your current Activity or Application.
    #
    #     public <return type> calabashBackdoor(String param1, int param2)
    #
    # @example
    #   # iOS
    #   backdoor('calabashBackdoor:', '')
    #
    # @example
    #   # iOS
    #   backdoor('calabashBackdoor:', {example:'param'})
    #
    # @example
    #   # Android
    #   backdoor('calabashBackdoor', 'first argument', 2)
    #
    # @param [String] name The selector/method name.
    # @param [Object] arguments A comma separated list of arguments to be
    #  passed to the backdoor selector/method.
    # @return [Object] the result of performing the selector/method with the
    #  arguments (serialized)
    def backdoor(name, *arguments)
      Device.default.backdoor(name, *arguments)
    end

    # @!visibility private
    def _evaluate_javascript_in(query, javascript)
      abstract_method!
    end
  end
end
