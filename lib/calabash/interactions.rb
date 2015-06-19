module Calabash
  module Interactions
    # @todo Needs docs!
    def query(query, *args)
      Calabash::Device.default.map_route(Query.new(query), :query, *args)
    end

    # @todo Needs docs!
    def flash(query)
      Calabash::Device.default.map_route(Query.new(query), :flash)
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
    # For iOS
    # You must create a method on you app delegate of the form:
    #
    #     - (NSString *) calabashBackdoor:(NSString *)aIgnorable;
    #
    # or if you want to pass parameters
    #
    #     - (NSString *) calabashBackdoor:(NSDictionary *)params;
    #
    # For Android
    # You must create a public method in your current Activity or Application.
    #
    #     public <return type> calabashBackdoor(String param1, int param2)
    #
    # @example
    #   # iOS
    #   backdoor('calabashBackdoor:'', '')
    #
    # @example
    #   # iOS
    #   backdoor('calabashBackdoor:', {example:'param'})
    #
    # @example
    #   # Android
    #   backdoor('calabashBackdoor', 'first argument', 2)
    #
    # @param [String] The selector/method name.
    # @return [Object] the result of performing the selector/method with the
    #  arguments (serialized)
    def backdoor(name, *arguments)
      Device.default.backdoor(name, *arguments)
    end
  end
end
