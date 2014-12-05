module Calabash
  module Gestures
    def touch(query, options={})
      _touch(query, options)
    end

    private

    # @!visibility private
    def _touch(query, options={})
      abstract_method!
    end
  end
end