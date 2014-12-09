module Calabash
  class Logger
    attr_accessor :default_log_level

    def initialize(output=nil)
      @output = output || STDOUT.dup
      @default_log_level = :info
    end

    # Log a message
    #
    # @param [String] message to log
    # @param [Symbol] log level
    #  Can be one of `{:info | :debug | :warn | :error }`
    def log(message, log_level = default_log_level)
      @output.write("#{message}\n") if should_log?(log_level)
    end

    private

    # @!visibility private
    def should_log?(log_level)
      Logger.log_levels.include?(log_level)
    end

    public

    @@log_levels = [:info, :warn, :error]

    # Log a message to the default output
    #
    # @param [String] message to log
    # @param [Symbol] log level (:debug, :info, :warning, :error)
    #  Can be one of `{:info | :debug | :warn | :error }`
    def self.log(message, log_level = :info)
      Logger.new.log(message, log_level)
    end

    # The log levels of the logger
    #
    # @return [Array] log levels
    def self.log_levels
      @@log_levels
    end

    # Set the log levels of the logger
    #
    # @param [Array] log levels
    def self.log_levels=(log_levels)
      @@log_levels = log_levels
    end
  end
end
