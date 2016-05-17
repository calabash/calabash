module Calabash
  module CLI
    module Doctor

      class DirIllness < ManualCureIllness

        CHECK_PATH = '/tmp/calabash_doctor'

        def diagnose
          if Dir.exist?(CHECK_PATH)
            well("#{CHECK_PATH} exists")
          else
            ill("#{CHECK_PATH} does NOT exist")
          end
        end

        def cure
          "Manually create a directory at: #{CHECK_PATH}"
        end
      end

      class FileIllness < AutoCureIllness

        CHECK_PATH = '/tmp/calabash_doctor/cure'

        def diagnose
          if File.exist?(CHECK_PATH)
            well("#{CHECK_PATH} exists")
          else
            ill("#{CHECK_PATH} does NOT exist")
          end
        end

        def cure
          if should_cure?("Create the file: #{CHECK_PATH}")
            `touch #{CHECK_PATH}`
            true
          else
            false
          end
        end
      end
    end
  end
end