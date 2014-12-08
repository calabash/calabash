module Calabash
  module Utility
    def abstract_method!
      method_name = if Kernel.method_defined?(:caller_locations)
                      caller_locations.first.label
                    else
                      caller.first[/\`(.*)\'/, 1]
                    end

      raise "Abstract method '#{method_name}'"
    end
  end
end