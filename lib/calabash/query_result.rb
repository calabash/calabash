module Calabash
  # A QueryResult represents the returned value of a query.
  # It is an immutable collection of matches or the result of applied methods.
  # It will, unlike `Array`, raise an IndexError instead of returning nil if
  # an entry outside bounds is accessed.
  class QueryResult < Array
    def self.create(result, query)
      query_result = QueryResult.send(:new, query)
      query_result.send(:initialize_copy, result)
      recursive_freeze(query_result)
      query_result
    end

    private_class_method :new

    attr_reader :query

    def initialize(query)
      @query = Query.new(query)
    end

    def first(*several_variants)
      ensure_in_bounds(0)

      super(*several_variants)
    end

    def last(*several_variants)
      ensure_in_bounds(-1)

      super(*several_variants)
    end

    def [](index)
      ensure_in_bounds(index)

      super(index)
    end

    def at(index)
      ensure_in_bounds(index)

      super(index)
    end

    def fetch(*several_variants)
      unless block_given? || several_variants.length > 1
        ensure_in_bounds(several_variants.first)
      end

      super(*several_variants)
    end

    def ensure_in_bounds(index)
      if empty?
        raise IndexError, "Query result is empty"
      end

      if index > 0 && index >= length
        raise IndexError, "Index out of bounds [index: #{index}, length: #{length}]"
      end

      if index < 0 && -index > length
        raise IndexError, "Index out of bounds [index: #{index}, length: #{length}]"
      end
    end

    def self.recursive_freeze(object)
      if object.is_a?(Array)
        object.each do |entry|
          recursive_freeze(entry)
        end
      end

      if object.is_a?(Hash)
        object.each do |key, value|
          recursive_freeze(key)
          recursive_freeze(value)
        end
      end

      object.freeze
    end
  end
end
