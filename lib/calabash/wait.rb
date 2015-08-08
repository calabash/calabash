module Calabash

  # A public API for waiting for things to happen.
  module Wait
    # @!visibility private
    class TimeoutError < RuntimeError
    end

    # The default options used in the "wait" methods
    @@default_options =
        {
            # default upper limit on how long to wait
            timeout: Environment::WAIT_TIMEOUT,

            # default message (String or Proc) if timeout occurs
            message: lambda do |options|
              "Timed out after waiting for #{options[:timeout]} seconds..."
            end,

            # default polling frequency for waiting
            retry_frequency: 0.1,

            # default exception type to raise when the timeout is exceeded
            exception_class: Calabash::Wait::TimeoutError,

            # whether to embed a screenshot on failure
            screenshot_on_error: true
        }

    # Returns the default wait options.
    # @return [Hash] Key/value pairs describing the wait options.
    def self.default_options
      @@default_options
    end

    # Sets the default wait options.
    # @param [Hash] value The new default wait options.
    def self.default_options=(value)
      @@default_options = value
    end

    # Evaluates the block given. If the execution time of the block exceeds
    # `timeout` it will raise a TimeoutError.
    #
    # If you have an explicit or implicit loop in your block, or
    # you want to limit the possible execution time of your block, use
    # `with_timeout`.
    #
    # @example
    #  # If the 'PictureRow' view does not exist, keep scrolling down.
    #  with_timeout(15, 'Could not find picture row') do
    #    scroll_down until view_exists?("PictureRow")
    #  end
    #
    #  # Scroll down **at least once** and continue scrolling down until the
    #  # 'PictureRow' exists.
    #  wait_for(15, 'Could not find picture row') do
    #    scroll_down
    #    view_exists?("PictureRow")
    #  end
    #
    # @param [Number] timeout The time before failing
    # @param [String, Proc] timeout_message The error message if timed out
    # @param [Class] exception_class The exception type raised if timed out
    # @return The returned value of `block`
    # @raise [ArgumentError] If an invalid timeout is given (<= 0)
    # @raise [ArgumentError] If no timeout_message is given
    # @raise [ArgumentError] If no block is given
    def with_timeout(timeout, timeout_message, exception_class = TimeoutError, &block)
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
        fail(exception_class, message)
      end
    end

    # Evaluates the given block until the block evaluates to truthy. If the
    # block raises an error, it is **not** rescued.
    #
    # If the block does not evaluate to truthy within the given timeout
    # an TimeoutError will be raised.
    #
    # The default timeout will be `Wait.default_options[:timeout]`.
    #
    # @see Calabash::Wait#with_timeout
    # @see Calabash::Environment::WAIT_TIMEOUT
    # @see Calabash::Wait.default_options
    #
    # @param [String, Proc] timeout_message The error message if timed out.
    # @param [Hash] options Used to control the behavior of the wait.
    # @option options [Number] :timeout (30) How long to wait before timing out.
    # @option options [Number] :retry_frequency (0.3) How often to check for
    #  the condition block to be truthy.
    # @option options [Boolean] :screenshot_on_error (true) Take a screenshot
    #  if the block fails to be truthy or an error is raised in the block.
    # @return The returned value of `block` if it is truthy
    def wait_for(timeout_message, options={}, &block)
      wait_options = Wait.default_options.merge(options)
      timeout = wait_options[:timeout]

      with_timeout(timeout, timeout_message, wait_options[:exception_class]) do
        loop do
          value = block.call

          return value if value

          sleep(wait_options[:retry_frequency])
        end
      end
    end

    # Waits for `query` to match one or more views.
    #
    # @example
    #  wait_for_view({marked: 'mark'})
    #
    # @example
    #  text = wait_for_view("myview")['text']
    #
    # @param [String, Hash, Calabash::Query] query Query to match view
    # @see Calabash::Wait#with_timeout for options
    # @return [Hash] The first view matching `query`.
    def wait_for_view(query, options={})
      if query.nil?
        raise ArgumentError, 'Query cannot be nil'
      end

      defaults = Wait.default_options.dup

      defaults[:message] = lambda do |wait_options|
          "Waited #{wait_options[:timeout]} seconds for #{parse_query_list(query)} to match a view"
      end

      defaults[:exception_class] = ViewNotFoundError

      timeout_options = defaults.merge(options)

      wait_for(timeout_options[:message],
               {timeout: timeout_options[:timeout],
                exception_class: timeout_options[:exception_class],
                retry_frequency: timeout_options[:retry_frequency]}) do
        view_exists?(query)
      end.first
    end

    # Waits for all `queries` to simultaneously match at least one view.
    #
    # @param [String, Hash, Calabash::Query] queries List of queries or a
    #  query.
    #
    # @see Calabash::Wait#with_timeout for options
    # @return [void] The return value for this method is undefined.
    def wait_for_views(*queries, **options)
      if queries.nil? || queries.any?(&:nil?)
        raise ArgumentError, 'Query cannot be nil'
      end

      defaults = Wait.default_options.dup
      defaults[:message] = lambda do |wait_options|
          "Waited #{wait_options[:timeout]} seconds for #{parse_query_list(queries)} to each match a view"
      end

      defaults[:exception_class] = ViewNotFoundError

      timeout_options = defaults.merge(options)

      wait_for(timeout_options[:message],
               {timeout: timeout_options[:timeout],
                exception_class: timeout_options[:exception_class],
                retry_frequency: timeout_options[:retry_frequency]}) do
        views_exist?(*queries)
      end

      # Do not return the value of views_exist?(queries) as it clutters
      # a console environment
      true
    end

    # Waits for `query` not to match any views
    #
    # @param [String, Hash, Calabash::Query] query Query to match view
    # @see Calabash::Wait#with_timeout for options
    def wait_for_no_view(query, options={})
      if query.nil?
        raise ArgumentError, 'Query cannot be nil'
      end

      defaults = Wait.default_options.dup
      defaults[:message] = lambda do |wait_options|
        "Waited #{wait_options[:timeout]} seconds for #{parse_query_list(query)} to not match any view"
      end

      defaults[:exception_class] = ViewFoundError

      timeout_options = defaults.merge(options)

      wait_for(timeout_options[:message],
               {timeout: timeout_options[:timeout],
                exception_class: timeout_options[:exception_class],
                retry_frequency: timeout_options[:retry_frequency]}) do
        !view_exists?(query)
      end
    end

    # Waits for all `queries` to simultaneously match no views
    #
    # @param [String, Hash, Calabash::Query] queries List of queries or a
    #  query.
    #
    # @see Calabash::Wait#with_timeout for options
    def wait_for_no_views(*queries, **options)
      if queries.nil? || queries.any?(&:nil?)
        raise ArgumentError, 'Query cannot be nil'
      end

      defaults = Wait.default_options.dup
      defaults[:message] = lambda do |wait_options|
        "Waited #{wait_options[:timeout]} seconds for #{parse_query_list(queries)} to each not match any view"
      end

      defaults[:exception_class] = ViewFoundError

      timeout_options = defaults.merge(options)

      wait_for(timeout_options[:message],
               {timeout: timeout_options[:timeout],
                exception_class: timeout_options[:exception_class],
                retry_frequency: timeout_options[:retry_frequency]}) do
        !views_exist?(*queries)
      end
    end

    # Does the given `query` match at least one view?
    #
    # @param [String, Hash, Calabash::Query] query Query to match view
    # @return [Object] Returns truthy if the `query` matches at least one view
    # @raise [ArgumentError] If given an invalid `query`
    def view_exists?(query)
      if query.nil?
        raise ArgumentError, 'Query cannot be nil'
      end

      result = query(query)

      if result.empty?
        false
      else
        result
      end
    end

    # Does the given `queries` all match at least one view?
    #
    # @param [String, Hash, Calabash::Query] queries List of queries or a
    #  query
    #
    # @return Returns truthy if the `queries` all match at least one view
    # @raise [ArgumentError] If given an invalid list of queries
    def views_exist?(*queries)
      if queries.nil? || queries.any?(&:nil?)
        raise ArgumentError, 'Query cannot be nil'
      end

      results = queries.map{|query| view_exists?(query)}

      if results.all?
        results
      else
        false
      end
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
              "No view matched #{parse_query_list(query)}"
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
              "Not all queries #{parse_query_list(queries)} matched a view"
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
        raise ViewFoundError, "A view matched #{parse_query_list(query)}"
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
              "Some views matched #{parse_query_list(queries)}"
      end

      true
    end

    alias_method :views_should_not_exist, :do_not_expect_views

    # Waits for a view containing `text`.
    #
    # @param text [String] Text to look for
    # @return [Object] The view matched by the text query
    # @see Calabash::Wait#wait_for_view
    def wait_for_text(text, options={})
      wait_for_view("* {text CONTAINS[c] '#{text}'}", options)
    end

    # Waits for no views containing `text`.
    #
    # @param text [String] Text to look for
    # @see Calabash::Wait#wait_for_no_view
    def wait_for_text_to_disappear(text, options={})
      wait_for_no_view("* {text CONTAINS[c] '#{text}'}", options)
    end

    # Raises an exception. Embeds a screenshot if
    # Calabash::Wait#default_options[:screenshot_on_error] is true. The fail
    # method should be used when the test should fail and stop executing. Do
    # not use fail if you intent on rescuing the error raised without
    # re-raising.
    #
    # @example
    #  unless view_exists?("* marked:'login'")
    #    fail('Did not see "login" button')
    #  end
    #
    # @example
    #  entries = query("ListEntry").length
    #
    #  if entries < 5
    #    fail(MyError, "Should see at least 5 entries, saw #{entries}")
    #  end
    #
    # @raise [RuntimeError, StandardError] By default, raises a RuntimeError with
    #  `message`.  You can pass in your own Exception class to override the
    #  the default behavior.
    def fail(*several_variants)
      arg0 = several_variants[0]
      arg1 = several_variants[1]

      if arg1.nil?
        exception_type = RuntimeError
        message = arg0
      else
        exception_type = arg0
        message = arg1
      end

      screenshot_embed if Wait.default_options[:screenshot_on_error]

      raise exception_type, message
    end

    # Raises an exception and always embeds a screenshot
    #
    # @raise [RuntimeError, StandardError] By default, raises a RuntimeError with
    #  `message`.  You can pass in your own Exception class to override the
    #  the default behavior.
    # @see Wait#fail
    def screenshot_and_raise(*several_variants)
      arg0 = several_variants[0]
      arg1 = several_variants[1]

      if arg1.nil?
        exception_type = RuntimeError
        message = arg0
      else
        exception_type = arg0
        message = arg1
      end

      screenshot_embed

      raise exception_type, message
    end

    # @!visibility private
    def parse_query_list(queries)
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
    class PrivateWaitTimeoutError < RuntimeError
    end

  end
end
