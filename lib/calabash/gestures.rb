module Calabash
  module Gestures
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
