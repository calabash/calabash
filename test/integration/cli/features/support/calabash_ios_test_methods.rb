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

    module IOSInternal
      def ios_test
        :ios_test
      end

      def _specific_implementation
        :ios_implementation
      end
    end
  end
end