module Calabash
  # @!visibility private
  module Patch
    require 'calabash/patch/array'

    def self.apply_patches!
      modules = Patch.constants(false)

      modules.each do |constant|
        Calabash.const_get(constant).send(:include, const_get(constant))
      end
    end
  end
end
