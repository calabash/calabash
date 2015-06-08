module Calabash
  module Android
    module Build
      # @!visibility private
      class TestServer
        def initialize(application_path)
          @application_path = application_path
        end

        def path
          File.expand_path("test_servers/#{checksum(@application_path)}_#{VERSION}.apk")
        end

        def exists?
          File.exists?(path)
        end

        private

        def checksum(file_path)
          require 'digest/md5'
          Digest::MD5.file(file_path).hexdigest
        end
      end
    end
  end
end
