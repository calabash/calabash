module Calabash

  # A representation of a Calabash query.
  # @todo Query needs more documentation.
  # @todo Query needs some methods moved to private or doc'd private.
  class Query
    # @!visibility private
    def self.web_query?(query_string)
      # :no, :double or :single
      in_quotes = :no

      # Number of slashes before the current char
      slash_count = 0

      # If the query starts with css: or xpath:
      # We could change the regex from /(\s|\'|\")css:/ to /(^|\s|\'|\")css:/
      # and change if (query[i, indicator[:length]] =~ indicator[:regex]) == 0
      # to if (query[0, i+indicator[:length]] =~ indicator[:regex]) == i
      # (not working)
      # to avoid having to do this check.
      results = WEB_QUERY_INDICATORS.map do |indicator|
        query_string =~ /^\s*#{indicator[:string]}/
      end

      if results.any?
        return true
      end

      length = query_string.length

      length.times do |i|
        char = query_string[i]

        if char == "\\"
          slash_count += 1
          next
        end

        if char == "'"
          if slash_count == 0
            if in_quotes == :no
              in_quotes = :single
            elsif in_quotes == :single
              in_quotes = :no
            end
          end
        elsif char == '"'
          if slash_count == 0
            if in_quotes == :no
              in_quotes = :double
            elsif in_quotes == :double
              in_quotes = :no
            end
          end
        end

        if slash_count == 0 && in_quotes == :no
          WEB_QUERY_INDICATORS.each do |indicator|
            if (query_string[i, indicator[:length]] =~ indicator[:regex]) == 0
              return true
            end
          end
        end

        slash_count = 0
      end

      false
    end

    # @!visibility private
    def self.query_hash_to_string(hash)
      result = hash.fetch(:class, '*')

      if hash[:marked] && (hash[:id] || hash[:text])
        raise 'Cannot use both marked and id/text'
      end

      if hash[:marked]
        result = "#{result} marked:'#{Text.escape_single_quotes(hash[:marked])}'"
      end

      if hash[:id]
        result = "#{result} id:'#{Text.escape_single_quotes(hash[:id])}'"
      end

      if hash[:text]
        result = "#{result} text:'#{Text.escape_single_quotes(hash[:text])}'"
      end

      if hash[:index]
        result = "#{result} index:#{hash[:index]}"
      end

      if hash[:css]
        result = "#{result} css:'#{Text.escape_single_quotes(hash[:css])}'"
      end

      if hash[:xpath]
        result = "#{result} xpath:'#{Text.escape_single_quotes(hash[:xpath])}'"
      end

      result
    end

    def initialize(query)
      unless query.is_a?(Query) || query.is_a?(Hash) || query.is_a?(String)
        raise ArgumentError, "Invalid argument for query: '#{query}' (#{query.class})"
      end

      @query = query.dup

      freeze
    end

    def to_s
      if @query.is_a?(Query)
        @query.to_s
      elsif @query.is_a?(Hash)
        Query.query_hash_to_string(@query)
      else
        @query.dup
      end
    end

    def inspect
      "<Calabash::Query #{@query.inspect}>"
    end

    def web_query?
      Query.web_query?(to_s)
    end

    WEB_QUERY_INDICATORS =
        [
            {
                string: 'css:',
                regex: /(\s|\'|\")css:/,
                length: 5
            },
            {
                string: 'xpath:',
                regex: /(\s|\'|\")xpath:/,
                length: 7
            }
        ]

    # @!visibility private
    def self.valid_query?(query)
      query.is_a?(String) || query.is_a?(Hash) || query.is_a?(Query)
    end

    # @!visibility private
    def self.ensure_valid_query(query)
      unless valid_query?(query)
        raise ArgumentError, "invalid query '#{query}' (#{query.class})"
      end
    end
  end
end
