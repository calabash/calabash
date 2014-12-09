module Calabash
  module CLI
    module Console
      def parse_console_arguments!
        application = @arguments.shift

        if application.nil?
          Logger.info("No application specified. Using default application specified by env variable CALABASH_APP")
          application = Environment.default_application_path
          Logger.debug("New application: '#{application}'")

          fail("No application given and CALABASH_APP is not set.", :console) if application.nil?
        end

        if File.exists?(application)
          require_relative '../../../old/android/ruby-gem/bin/calabash-android-console'
          calabash_console(application)
        else
          fail("File '#{application}' does not exist", :console)
        end
      end
    end
  end
end