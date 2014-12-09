module Calabash
  module CLI
    module Resign
      def parse_resign_arguments!
        fail('Can only resign Android applications') unless @options[:platform].nil? || @options[:platform] == 'android'

        application = @arguments.shift

        if application.nil?
          fail('Must supply application as first parameter to resign', :resign)
        elsif !File.exists?(application)
          fail("File '#{application}' does not exist", :resign)
        else
          extension = File.extname(application)

          case extension
            when '.apk'
              @options[:platform] ||= :android
              Calabash::Android::Build::Resigner.new(application).resign!
            when '.ipa', '.app'
              @options[:platform] ||= :ios
              fail('Should only build test-server for Android')
            else
              fail('Application must be an apk', :resign)
          end
        end
      end

    end
  end
end