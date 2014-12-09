module Calabash
  module CLI
    module Build
      def parse_build_arguments!
        application = @arguments.shift

        if application.nil?
          fail('Must supply application as first parameter to build')
        elsif !File.exists?(application)
          fail("File '#{application}' does not exist")
        else
          extension = File.extname(application)

          case extension
            when '.apk'
              @options[:platform] = :android
              require(File.join('..', 'bin', 'calabash-android-build'))
              calabash_build(application)
            when '.ipa', '.app'
              @options[:platform] = :ios
              fail('Should only build test-server for Android')
            else
              fail('Application must be an apk')
          end
        end
      end

    end
  end
end