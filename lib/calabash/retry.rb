module Calabash
  module Retry
    DEFAULT_INTERVAL = 0.5

    def self.retry(retries: nil, interval: DEFAULT_INTERVAL, timeout: nil, on_errors: [StandardError], &block)
      if retries.nil?
        raise ArgumentError, "Must supply retries"
      end

      if retries < 1
        raise ArgumentError, "'retries' must be greater or equal to 1, it is #{retries}"
      end

      last_error = nil
      start_time = Time.now

      retries.times do
        begin
          return block.call
        rescue *on_errors => e
          last_error = e
          sleep interval

          if timeout && Time.now - start_time > timeout
            break
          end
        end
      end

      raise last_error
    end
  end
end