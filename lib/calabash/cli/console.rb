module Calabash
  module CLI
    module Console
      def parse_console_arguments!
        application = @arguments.shift

        if application.nil?
          Logger.info("No application specified. Using default application specified by env variable CALABASH_APP")
          application = Environment.default_application_path
          Logger.debug("New application: '#{application}'")

          fail("No application given and env variable CALABASH_APP is not set.", :console) if application.nil?
        end

        if File.exists?(application)
          extension = File.extname(application)

          #TODO: Fail when wrong platform and apk etc.

          case extension
            when '.apk'
              @options[:platform] ||= :android
              # This is very wrong
              require_old_android_bin
              calabash_console(application)
            when '.ipa'
              @options[:platform] ||= :ios
              # TODO: Extract ID from ipa
              raise 'FOR NOW WE CANT DO THIS'
            when '.app'
              @options[:platform] ||= :ios
              Environment.set_variable!('APP_BUNDLE_PATH', application)
              # This is very wrong
              require_old_ios_bin
              console
            else
              fail('Application must be either an .apk, .ipa or .app', :console)
          end
        else
          fail("File '#{application}' does not exist", :console)
        end
      end
    end
  end
end