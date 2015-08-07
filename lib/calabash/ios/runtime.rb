module Calabash
  module IOS
    module Runtime

      # @todo Complete and document the Runtime API
      def simulator?
        Calabash::IOS::Device.default.simulator?
      end

      def physical_device?
        Calabash::IOS::Device.default.physical_device?
      end
    end
  end
end
