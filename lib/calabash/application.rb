require 'digest'

module Calabash
  # A representation of the application that is under test.
  class Application
    include Calabash::Utility

    @@default = nil

    def self.default
      @@default
    end

    def self.default=(value)
      @@default = value
    end

    attr_reader :path

    def self.from_path(path)
      extension = File.extname(path)

      case extension
        when '.apk'
          Android::Application.new(path, nil)
        when '.ipa', '.app'
          IOS::Application.new(path)
        else
          Application.new(path)
      end
    end

    # @raise [RuntimeError] Raises an error if `application_path` does not
    #   exist.
    def initialize(application_path, options = {})
      if application_path.nil?
        raise ArgumentError, "Invalid application path '#{application_path}'."
      end

      @path = File.expand_path(application_path)
      @logger = options[:logger] || Calabash::Logger.new
      @identifier = options[:identifier]
      ensure_application_path
    end

    def extract_identifier
      abstract_method!
    end

    def identifier
      @identifier ||= extract_identifier
    end

    def md5_checksum
      Digest::MD5.file(path).hexdigest
    end

    private

    def ensure_application_path
      unless File.exist?(path)
        raise "'#{path}' does not exist."
      end
    end
  end
end
