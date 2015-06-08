module Calabash
  # @!visibility private
  module CLI
    # @!visibility private
    module Resign
      def parse_resign_arguments!
        fail('Can only resign Android applications') unless @platform.nil? || @platform == :android

        application = @arguments.shift

        if application.nil?
          fail('Must supply application as first parameter to resign', :resign)
        elsif !File.exists?(application)
          fail("File '#{application}' does not exist", :resign)
        else
          extension = File.extname(application)

          case extension
            when '.apk'
              set_platform!(:android)
              Calabash::Android::Build::Resigner.new(application).resign!
            when '.ipa', '.app'
              set_platform!(:ios)
              fail('Can only resign Android applications (apk)')
            else
              fail('Application must be an apk', :resign)
          end
        end
      end

    end
  end
end
