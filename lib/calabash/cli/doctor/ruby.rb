module Calabash
  module CLI
    module Doctor

      class OldRubyIllness < ManualCureIllness

        def diagnose
          version20 = RunLoop::Version.new('2.0')
          if RunLoop::Version.new(RUBY_VERSION) >= version20
            well('Ruby version meets the requirements')
          else
            ill('Ruby version 2.0 or newer is required')
          end
        end

        def cure
          'Manually upgrade to Ruby 2.0 or newer (eg with rvm or rbenv)'
        end
      end
    end
  end
end