module Calabash
  module CLI
    module Generate
      def parse_generate_arguments!
        platform = @arguments.shift

        if platform.nil?
          fail('No platform given', :gen)
        else
          case platform.downcase.to_sym
            when :android
              require_old_android_bin
              calabash_scaffold
            when :ios
              require_old_ios_bin
              calabash_scaffold
            else #TODO: Add cross-platform
              fail("Invalid platform '#{platform}'", :gen)
          end
        end
      end
    end
  end
end