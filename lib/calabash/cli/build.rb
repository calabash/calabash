module Calabash
  module CLI
    # @!visibility private
    module Build
      # @!visibility private
      def parse_build_arguments!
        fail('Should only build test-server for Android') unless @platform.nil? || @platform == :android

        application = @arguments.shift
        test_server_path = nil

        arg = @arguments.shift

        if arg != nil
          if arg == '-o'
            test_server_path = @arguments.shift

            if test_server_path == nil
              raise 'Expected an output path for the test-server'
            end
          end
        end

        if application.nil?
          fail('Must supply application as first parameter to build', :build)
        elsif !File.exists?(application)
          fail("File '#{application}' does not exist", :build)
        else
          extension = File.extname(application)
          application_path = File.expand_path(application)

          case extension
            when '.apk'
              set_platform!(:android)
              Calabash::Android::Build::Builder.new(application_path).build(test_server_path)
            when '.ipa', '.app'
              set_platform!(:ios)
              fail('Should only build test-server for Android')
            else
              fail('Application must be an apk', :build)
          end
        end
      end

    end
  end
end
