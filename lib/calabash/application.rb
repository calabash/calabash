require 'digest'

module Calabash
  # A representation of an application that is under test.
  class Application
    require 'calabash/android/application'
    require 'calabash/ios/application'

    # @!visibility private
    include Calabash::Utility

    # @!visibility private
    @@default = nil

    # @!visibility private
    def self.default
      @@default
    end

    # @!visibility private
    def self.default=(value)
      @@default = value
    end

    attr_reader :path

    # Get the application from the default environment.
    def self.default_from_environment
      application_path = Environment::APP_PATH

      if application_path.nil?
        raise 'No application path is set. Specify application with environment variable CAL_APP'
      end

      unless File.exist?(application_path)
        raise "Application '#{application_path}' does not exist"
      end

      Application.from_path(application_path)
    end

    # Create an application from a path
    #
    # @return [Calabash::Android::Application, Calabash::IOS::Application] An
    #  application for `path`.
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

    # Is this application an android application
    #
    # @return [Boolean] true if this application is an android application
    def android_application?
      false
    end

    # Is this application an iOS application
    #
    # @return [Boolean] true if this application is an iOS application
    def ios_application?
      false
    end

    # @!visibility private
    def to_s
      "#<Application #{path}>"
    end

    # @!visibility private
    def inspect
      to_s
    end

    # @!visibility private
    def extract_identifier
      abstract_method!
    end

    # The identifier of the app. On iOS this is known as the bundle id, on
    # Android this is known as the package. If the application has not been
    # given an identifier in #initialize, this method will try to extract the
    # identifier of the app.
    #
    # @return [String] The identifier if the app
    def identifier
      @identifier ||= extract_identifier
    end

    # @!visibility private
    def md5_checksum
      Digest::MD5.file(path).hexdigest
    end

    private

    # @!visibility private
    def ensure_application_path
      unless File.exist?(path)
        raise "The app '#{path}' does not exist."
      end
    end
  end
end
