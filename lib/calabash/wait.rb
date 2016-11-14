module Calabash

  # A public API for waiting for things to happen.
  module Wait
    # Default error indicating a timeout
    class TimeoutError < RuntimeError
    end

    # The default options used in the "wait" methods
    @@default_options =
        {
            # default upper limit on how long to wait
            timeout: Environment::WAIT_TIMEOUT,

            # default message (String or Proc) if timeout occurs
            timeout_message: lambda do |options|
              "Timed out after waiting for #{options[:timeout]} seconds..."
            end,

            # default polling frequency for waiting
            retry_frequency: 0.1,

            # default exception type to raise when the timeout is exceeded
            exception_class: Calabash::Wait::TimeoutError
        }

    # Returns the default wait options.
    #
    # @example
    #  # Get the current timeout message
    #  Calabash::Wait.default_options[:timeout_message]
    #
    # @example
    #  Calabash::Wait.default_options[:timeout] = 60
    #
    # @see @@default_options
    # @return [Hash] Key/value pairs describing the wait options.
    def self.default_options
      @@default_options
    end

    # Evaluates the block given. If the execution time of the block exceeds
    # `timeout` it will raise a `exception_class` (default:
    # {Calabash::Wait.default_options
    # Calabash::Wait.default_options[:exception_class]}).
    #
    # If you have an explicit or implicit loop in your block, or
    # you want to limit the possible execution time of your block, use
    # {Calabash::Wait#with_timeout cal.with_timeout}
    #
    # @example
    #  # If the 'PictureRow' view does not exist, keep panning up.
    #  cal.with_timeout(15, 'Could not find picture row') do
    #    cal.pan_screen_up until cal.view_exists?("PictureRow")
    #  end
    #
    # @example
    #  # Pan up **at least once** and continue pan up until the
    #  # 'PictureRow' exists.
    #  cal.wait_for('Could not find picture row') do
    #    cal.pan_screen_up
    #    cal.view_exists?("PictureRow")
    #  end
    #
    # @param [Number] timeout The time before failing
    # @param [String, Proc] timeout_message The error message if timed out
    # @param [Class] exception_class
    #  (default: {Calabash::Wait.default_options
    #  Calabash::Wait.default_options[:exception_class]}) The exception type
    #  raised if timed out
    # @return The returned value of the block given
    # @raise [ArgumentError] If an invalid timeout is given (<= 0)
    # @raise [ArgumentError] If no timeout_message is given
    # @raise [ArgumentError] If no block is given
    def with_timeout(timeout, timeout_message,
                     exception_class: Wait.default_options[:exception_class],
                     &block)
      if timeout_message.nil? ||
          (timeout_message.is_a?(String) && timeout_message.empty?)
        raise ArgumentError, 'You must provide a timeout message'
      end

      unless block_given?
        raise ArgumentError, 'You must provide a block'
      end

      # Timeout.timeout will never timeout if the given `timeout` is zero.
      # We will raise an exception if the timeout is zero.
      # Timeout.timeout already raises an exception if `timeout` is negative.
      if timeout == 0
        raise ArgumentError, 'Timeout cannot be 0'
      end

      message = if timeout_message.is_a?(Proc)
                  timeout_message.call({timeout: timeout})
                else
                  timeout_message
                end

      failed = false

      begin
        Timeout.timeout(timeout, PrivateWaitTimeoutError) do
          return block.call
        end
      rescue PrivateWaitTimeoutError => _
        # If we raise Timeout here the stack trace will be cluttered and we
        # wish to show the user a clear message, avoiding
        # "`rescue in with_timeout':" in the stack trace.
        failed = true
      end

      if failed
        raise exception_class, message
      end
    end

    # Evaluates the given block until the block evaluates to truthy. If the
    # block raises an error, it is **not** rescued.
    #
    # If the block does not evaluate to truthy within the given timeout
    # an TimeoutError will be raised.
    #
    # The default timeout will be {Calabash::Wait.default_options
    # Wait.default_options[:timeout]}.
    #
    # @example
    #  # Pan up **at least once** and continue pan up until the
    #  # 'PictureRow' exists.
    #  cal.wait_for('Could not find picture row') do
    #    cal.pan_screen_up
    #    cal.view_exists?("PictureRow")
    #  end
    #
    # @see Calabash::Wait#with_timeout
    #
    # @param [String, Proc] timeout_message The error message if timed out.
    # @param [Number] timeout (default: {Calabash::Wait.default_options
    #  Calabash::Wait.default_options[:timeout]}) The time before
    # @param [Number] retry_frequency (default: {Calabash::Wait.default_options
    #  Calabash::Wait.default_options[:retry_frequency]}) How often to check
    #  for the block to be truthy
    # @param [Class] exception_class
    #  (default: {Calabash::Wait.default_options
    #  Calabash::Wait.default_options[:exception_class]}) The exception type
    #  raised if timed out
    # @return The returned value of `block` if it is truthy
    def wait_for(timeout_message,
                 timeout: Calabash::Wait.default_options[:timeout],
                 retry_frequency: Calabash::Wait.default_options[:retry_frequency],
                 exception_class: Calabash::Wait.default_options[:exception_class],
                 &block)
      with_timeout(timeout, timeout_message,
                   exception_class: exception_class) do
        loop do
          value = block.call

          return value if value

          sleep(retry_frequency)
        end
      end
    end

    # Waits for `query` to match one or more views.
    #
    # @example
    #  cal.wait_for_view({marked: 'mark'})
    #
    # @example
    #  cal.wait_for_view({marked: 'login'},
    #                  timeout_message: "Did not see login button")
    #
    # @example
    #  text = cal.wait_for_view("myview")['text']
    #
    # @see Calabash::Wait#wait_for for optional parameters
    #
    # @param [String, Hash, Calabash::Query] query Query to match view
    # @return [Hash] The first view matching `query`.
    # @raise [ViewNotFoundError] If `query` do not match at least one view.
    def wait_for_view(query,
                      timeout: Calabash::Wait.default_options[:timeout],
                      timeout_message: nil,
                      retry_frequency: Calabash::Wait.default_options[:retry_frequency])
      if query.nil?
        raise ArgumentError, 'Query cannot be nil'
      end

      timeout_message ||= lambda do |wait_options|
          "Waited #{wait_options[:timeout]} seconds for #{Wait.parse_query_list(query)} to match a view"
      end

      wait_for(timeout_message,
               timeout: timeout,
               retry_frequency: retry_frequency,
               exception_class: ViewNotFoundError) do
        result = query(query)
        !result.empty? && result
      end.first
    end

    # Waits for all `queries` to simultaneously match at least one view.
    #
    # @example
    #  cal.wait_for_views({id: 'foo'}, {id: 'bar'})
    #
    # @see Calabash::Wait#wait_for for optional parameters
    #
    # @param [String, Hash, Calabash::Query] queries List of queries or a
    #  query.
    # @return The returned value is undefined
    # @raise [ViewNotFoundError] If `queries` do not all match at least one
    #  view.
    def wait_for_views(*queries,
                       timeout: Calabash::Wait.default_options[:timeout],
                       timeout_message: nil,
                       retry_frequency: Calabash::Wait.default_options[:retry_frequency])
      if queries.nil? || queries.any?(&:nil?)
        raise ArgumentError, 'Query cannot be nil'
      end

      timeout_message ||= lambda do |wait_options|
          "Waited #{wait_options[:timeout]} seconds for #{Wait.parse_query_list(queries)} to each match a view"
      end

      wait_for(timeout_message,
               timeout: timeout,
               retry_frequency: retry_frequency,
               exception_class: ViewNotFoundError) do
        views_exist?(*queries)
      end

      # Do not return the value of views_exist?(queries) as it clutters
      # a console environment
      true
    end

    # Waits for `query` not to match any views
    #
    # @example
    #  cal.wait_for_no_view({marked: 'mark'})
    #
    # @example
    #  cal.wait_for_no_view({marked: 'login'},
    #                  timeout_message: "Login button did not disappear")
    #
    # @see Calabash::Wait#wait_for for optional parameters
    #
    # @param [String, Hash, Calabash::Query] query Query to match view
    # @raise [ViewFoundError] If `query` do not match at least one view.
    def wait_for_no_view(query,
                         timeout: Calabash::Wait.default_options[:timeout],
                         timeout_message: nil,
                         retry_frequency: Calabash::Wait.default_options[:retry_frequency])
      if query.nil?
        raise ArgumentError, 'Query cannot be nil'
      end

      timeout_message ||= lambda do |wait_options|
        "Waited #{wait_options[:timeout]} seconds for #{Wait.parse_query_list(query)} to not match any view"
      end

      wait_for(timeout_message,
               timeout: timeout,
               retry_frequency: retry_frequency,
               exception_class: ViewFoundError) do
        !view_exists?(query)
      end
    end

    # Waits for all `queries` to simultaneously match no views
    #
    # @example
    #  cal.wait_for_no_views({id: 'foo'}, {id: 'bar'})
    #
    # @see Calabash::Wait#wait_for for optional parameters
    #
    # @param [String, Hash, Calabash::Query] queries List of queries or a
    #  query.
    # @raise [ViewNotFoundError] If `queries` do not all match at least one
    #  view.
    def wait_for_no_views(*queries,
                          timeout: Calabash::Wait.default_options[:timeout],
                          timeout_message: nil,
                          retry_frequency: Calabash::Wait.default_options[:retry_frequency])
      if queries.nil? || queries.any?(&:nil?)
        raise ArgumentError, 'Query cannot be nil'
      end

      timeout_message ||= lambda do |wait_options|
        "Waited #{wait_options[:timeout]} seconds for #{Wait.parse_query_list(queries)} to each not match any view"
      end

      wait_for(timeout_message,
               timeout: timeout,
               retry_frequency: retry_frequency,
               exception_class: ViewFoundError) do
        !views_exist?(*queries)
      end
    end

    # Does the given `query` match at least one view?
    #
    # @param [String, Hash, Calabash::Query] query Query to match view
    # @return [Boolean] Returns true if the `query` matches at least one view
    # @raise [ArgumentError] If given an invalid `query`
    def view_exists?(query)
      if query.nil?
        raise ArgumentError, 'Query cannot be nil'
      end

      result = query(query)

      !result.empty?
    end

    # Does the given `queries` all match at least one view?
    #
    # @param [String, Hash, Calabash::Query] queries List of queries or a
    #  query
    # @return [Boolean] Returns true if the `queries` all match at least one
    #  view
    # @raise [ArgumentError] If given an invalid list of queries
    def views_exist?(*queries)
      if queries.nil? || queries.any?(&:nil?)
        raise ArgumentError, 'Query cannot be nil'
      end

      results = queries.map{|query| view_exists?(query)}

      results.all?
    end

    # Expect `query` to match at least one view. Raise an exception if it does
    # not.
    #
    # @param [String, Hash, Calabash::Query] query Query to match a view
    # @raise [ArgumentError] If given an invalid `query`
    # @raise [ViewNotFoundError] If `query` does not match at least one view
    def expect_view(query)
      if query.nil?
        raise ArgumentError, 'Query cannot be nil'
      end

      unless view_exists?(query)
        raise ViewNotFoundError,
              "No view matched #{Wait.parse_query_list(query)}"
      end

      true
    end

    alias_method :view_should_exist, :expect_view

    # Expect `queries` to each match at least one view. Raise an exception if
    # they do not.
    #
    # @param [String, Hash, Calabash::Query] queries List of queries or a
    #  query.
    # @raise [ArgumentError] If given an invalid list of queries
    # @raise [ViewNotFoundError] If `queries` do not all match at least one
    #   view.
    def expect_views(*queries)
      if queries.nil? || queries.any?(&:nil?)
        raise ArgumentError, 'Query cannot be nil'
      end

      unless views_exist?(*queries)
        raise ViewNotFoundError,
              "Not all queries #{Wait.parse_query_list(queries)} matched a view"
      end

      true
    end

    alias_method :views_should_exist, :expect_views

    # Expect `query` to match no views. Raise an exception if it does.
    #
    # @param [String, Hash, Calabash::Query] query Query to match a view
    # @raise [ArgumentError] If given an invalid `query`
    # @raise [ViewFoundError] If `query` matches any views.
    def do_not_expect_view(query)
      if query.nil?
        raise ArgumentError, 'Query cannot be nil'
      end

      if view_exists?(query)
        raise ViewFoundError, "A view matched #{Wait.parse_query_list(query)}"
      end

      true
    end

    alias_method :view_should_not_exist, :do_not_expect_view

    # Expect `queries` to each match no views. Raise an exception if they do.
    #
    # @param [String, Hash, Calabash::Query] queries List of queries or a
    #  query.
    # @raise [ArgumentError] If given an invalid list of queries
    # @raise [ViewFoundError] If one of `queries` matched any views
    def do_not_expect_views(*queries)
      if queries.nil? || queries.any?(&:nil?)
        raise ArgumentError, 'Query cannot be nil'
      end

      if queries.map{|query| view_exists?(query)}.any?
        raise ViewFoundError,
              "Some views matched #{Wait.parse_query_list(queries)}"
      end

      true
    end

    alias_method :views_should_not_exist, :do_not_expect_views

    # Waits for a view containing `text`.
    #
    # @see Calabash::Wait#wait_for_view
    #
    # @param text [String] Text to look for
    # @return [Object] The view matched by the text query
    def wait_for_text(text,
                      timeout: Calabash::Wait.default_options[:timeout],
                      timeout_message: nil,
                      retry_frequency: Calabash::Wait.default_options[:retry_frequency])

      wait_for_view("* {text CONTAINS[c] '#{text}'}",
                    timeout: timeout,
                    timeout_message: timeout_message,
                    retry_frequency: retry_frequency)
    end

    # Waits for no views containing `text`.
    #
    # @see Calabash::Wait#wait_for_view
    #
    # @param text [String] Text to look for
    # @return [Object] The view matched by the text query
    def wait_for_no_text(text,
                         timeout: Calabash::Wait.default_options[:timeout],
                         timeout_message: nil,
                         retry_frequency: Calabash::Wait.default_options[:retry_frequency])

      wait_for_no_view("* {text CONTAINS[c] '#{text}'}",
                    timeout: timeout,
                    timeout_message: timeout_message,
                    retry_frequency: retry_frequency)
    end

    # Query matched an unexpected set of views
    class UnexpectedMatchError < RuntimeError
    end

    # View was found
    class ViewFoundError < UnexpectedMatchError
    end

    # View was not found
    class ViewNotFoundError < UnexpectedMatchError
    end
    
    # @!visibility private
    def self.parse_query_list(queries)
      unless queries.is_a?(Array)
        queries = [queries]
      end

      queries_dup = queries.map{|query| "\"#{Query.new(query).send(:formatted_as_string)}\""}

      if queries_dup.length == 0
        ''
      elsif queries_dup.length == 1
        queries_dup.first
      elsif queries_dup.length == 2
        "[#{queries_dup.first} and #{queries_dup.last}]"
      else
        "[#{queries_dup[0, queries_dup.length-1].join(',')}, and #{queries_dup.last}]"
      end
    end

    # @!visibility private
    class PrivateWaitTimeoutError < RuntimeError
    end

  end
end
