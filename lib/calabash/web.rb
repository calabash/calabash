module Calabash
  module Web
    # Evaluate javascript in a Web View. On iOS, an implicit return is
    # inserted, on Android an explicit return is needed.
    #
    # @example
    #  # iOS
    #  cal.evaluate_javascript_in("UIWebView", "2+2")
    #
    #  # Android
    #  cal.evaluate_javascript_in("WebView", "return 2+2")
    #
    # @example
    #  # iOS
    #  cal.evaluate_javascript_in("WKWebView",
    #         "document.body.style.backgroundColor = 'red';")
    #
    #  # Android
    #  cal.evaluate_javascript_in("XWalkContent",
    #         "document.body.style.backgroundColor = 'red';")
    #
    # @note No error will be raised if the javascript given is invalid, or
    #  throws an exception.
    #
    # @param [String, Hash, Calabash::Query] query Query that matches the
    #  webview
    # @param [String] javascript The javascript to evaluate
    #
    # @raise ViewNotFoundError If no views are found matching `query`
    def evaluate_javascript_in(query, javascript)
      wait_for_view(query,
                    timeout: Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT)

      _evaluate_javascript_in(query, javascript)
    end

    private

    # @!visibility private
    define_method(:_evaluate_javascript_in) do |query, javascript|
      abstract_method!
    end
  end
end