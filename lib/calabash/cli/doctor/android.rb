module Calabash
  module CLI
    module Doctor

      class NotSetAndroidHomeEnvVarIllness < NotSetPathEnvVarIllness

        def initialize
          @env_var = 'ANDROID_HOME'
        end

        def cure
          "#{super} to the path of your Android SDK"
        end
      end

      class MissingAndroidToolIllness < ManualCureIllness

        def initialize(tool_name, tool_sub_path)
          @tool_name = tool_name
          @tool_sub_path = tool_sub_path
        end

        def diagnose
          if (NotSetAndroidHomeEnvVarIllness.new.diagnose)[:ok]
            if File.exist?(File.join(ENV['ANDROID_HOME'], @tool_sub_path, @tool_name))
              well("The tool '#{@tool_name}' is installed")
            else
              ill("The tool '#{@tool_name}' is NOT installed")
            end
          else
            ill("The tool '#{@tool_name}' can't be found because 'ANDROID_HOME' is not set to a valid path")
          end
        end

        def cure
          if (NotSetAndroidHomeEnvVarIllness.new.diagnose)[:ok]
            "Manually install '#{@tool_name}' with the Android SDK Manager"
          else
            NotSetAndroidHomeEnvVarIllness.new.cure
          end
        end

        #TODO: Maybe this could use the is_windows? in Calabash::Android::Environment
        def is_windows?
          (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
        end
      end

      class MissingAndroidScriptIllness < MissingAndroidToolIllness

        def initialize
          tool_name = is_windows? ? 'android.bat' : 'android'
          super(tool_name, 'tools')
        end
      end

      class MissingAdbIllness < MissingAndroidToolIllness

        def initialize
          tool_name = is_windows? ? 'adb.exe' : 'adb'
          super(tool_name, 'platform-tools')
        end
      end

      class MissingAndroidEmulatorIllness < MissingAndroidToolIllness

        def initialize
          tool_name = is_windows? ? 'emulator.bat' : 'emulator'
          super(tool_name, 'tools')
        end
      end
    end
  end
end