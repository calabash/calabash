module Calabash
  module Android
    class Device < Calabash::Device
      def self.list_devices
        connected_devices
      end
    end
  end
end
