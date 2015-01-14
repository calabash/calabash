module Calabash
  class Application
    attr_reader :application_path

    # @raise [RuntimeError] Raises an error if `application_path` does not
    #   exist.
    def initialize(application_path, options = {})
      @application_path = File.expand_path(application_path)
      @logger = options[:logger] || Logger.new
      @identifier = options[:identifier]
      ensure_application_path
    end

    def extract_identifier
      raise 'cannot extract identifier'
    end

    def identifier
      @identifier ||= extract_identifier
    end

    private

    def ensure_application_path
      unless File.exist?(application_path)
        raise "'#{application_path}' does not exist."
      end
    end
  end
end