module Calabash
  class Application
    attr_reader :application_path

    def initialize(application_path, options = {})
      @application_path = application_path
      @logger = options[:logger] || Logger.new
    end
  end
end