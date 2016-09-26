if $_cal_methods_load
  module Calabash
    def test
      :test
    end

    def specific_implementation
      _specific_implementation
    end

    def _specific_implementation
      raise "Not implemented"
    end

    module AndroidInternal
      def android_test
        :android_test
      end

      def _specific_implementation
        :android_implementation
      end
    end
  end
end