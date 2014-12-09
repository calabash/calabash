module Calabash
  module CLI
    module Build
      def parse_build_arguments!
        fail('Should only build test-server for Android') unless @options[:platform].nil? || @options[:platform] == 'android'

        application = @arguments.shift

        if application.nil?
          fail('Must supply application as first parameter to build', :build)
        elsif !File.exists?(application)
          fail("File '#{application}' does not exist", :build)
        else
          extension = File.extname(application)

          case extension
            when '.apk'
              @options[:platform] ||= :android
              Calabash::Android::Build::Builder.new(application).build
            when '.ipa', '.app'
              @options[:platform] ||= :ios
              fail('Should only build test-server for Android')
            else
              fail('Application must be an apk', :build)
          end
        end
      end

    end
  end
end