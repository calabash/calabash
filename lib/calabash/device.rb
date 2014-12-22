module Calabash
  class Device
    include Utility

    class << self
      attr_accessor :default
    end

    attr_reader :serial

    def install(args)
      abstract_method!
    end

    def uninstall(args)
      abstract_method!
    end
  end
end