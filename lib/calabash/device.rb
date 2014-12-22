module Calabash
  class Device
    include Utility

    class << self
      attr_accessor :default
    end

    def install(args)
      abstract_method!
    end

    def uninstall(args)
      abstract_method!
    end
  end
end