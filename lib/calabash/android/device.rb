module Calabash
  module Android
    class Device < Calabash::Android::Operations::Device
      def self.list_devices
        connected_devices
      end
    end
  end
end
