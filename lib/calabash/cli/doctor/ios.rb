module Calabash
  module CLI
    module Doctor

      class MissingXcodeIllness < ManualCureIllness

        def diagnose
          begin
            path = `xcode-select --print-path`.chomp
            if Dir.exists?(path)
              well("Xcode is installed at: #{path}")
            else
              ill("Xcode can't be found at: #{path}")
            end
          rescue => e
            ill('Xcode is NOT installed')
          end
        end

        def cure
          'Manually install Xcode'
        end
      end

      class MissingXcodeCommandLineToolsIllness < AutoCureIllness

        def diagnose
          standalone_clt_id = 'com.apple.pkg.DeveloperToolsCLILeo'
          xcode_included_clt_id = 'com.apple.pkg.DeveloperToolsCLI'
          mavericks_clt_id = 'com.apple.pkg.CLTools_Executables'
          clt_found = false
          [standalone_clt_id, xcode_included_clt_id, mavericks_clt_id].each { |clt_id|
            require 'open3'
            package_info, _, _ = Open3.capture3("pkgutil --pkg-info=#{clt_id}")
            unless (package_info =~ /install-time:/).nil?
              clt_found = true
            end
          }
          if clt_found
            well('The Xcode Command Line Tools is installed')
          else
            ill('The Xcode Command Line Tools is NOT installed')
          end
        end

        def cure
          if should_cure?('Install Xcode Command Line Tools?')
            `xcode-select --install`
            true
          else
            false
          end
        end
      end

      class DevToolsSecurityIllness < AutoCureIllness

        def diagnose
          require 'open3'
          devtools_ouput, _, _ = Open3.capture3('DevToolsSecurity')
          if (devtools_ouput =~ /enabled/).nil?
            @should_enable_dev_tool_security = true
            ill('DevToolsSecurity is NOT enabled')
          else
            well('DevToolsSecurity is enabled')
          end
        end

        def cure
          if should_cure?('Enabling DevToolsSecurity')
            `DevToolsSecurity --enable`
            true
          else
            false
          end
        end
      end

      class AuthorizationDbIllness < AutoCureIllness

        def diagnose
          security_output, _, _ = Open3.capture3('security authorizationdb read system.privilege.taskport')
          if (security_output =~ /is-developer/).nil?
            @should_write_to_authorization_db = true
            ill('Authorization Database is NOT correctly set up')
          else
            well('Authorization Database is correctly set up')
          end
        end

        def cure
          if should_cure?('Updating authorization db')
            `security authorizationdb write system.privilege.taskport is-developer`
            true
          else
            false
          end
        end
      end
    end
  end
end