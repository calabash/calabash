module Calabash
  class Logger
    attr_accessor :default_log_level

    def initialize(output=nil)
      @output = output || STDOUT.dup
      @default_log_level = :debug
    end

    # Log a message
    #
    # @param [String] message to log
    # @param [Symbol] log_level
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

    if Environment::DEBUG
      @@log_levels = [:info, :warn, :error, :debug]
    else
      @@log_levels = [:info, :warn, :error]
    end

    # Log a message to the default output
    #
    # @param [String] message to log
    # @param [Symbol] log level (:debug, :info, :warning, :error)
    #  Can be one of `{:info | :debug | :warn | :error }`
    def self.log(message, log_level = :info)
      Logger.new.log(message, log_level)
    end

    # Log a message to the default output with log level :info
    #
    # @param [String] message to log
    def self.info(message)
      log(message, :info)
    end

    # Log a message to the default output with log level :debug
    #
    # @param [String] message to log
    def self.debug(message)
      log(message, :debug)
    end

    # Log a message to the default output with log level :warn
    #
    # @param [String] message to log
    def self.warn(message)
      log(message, :warn)
    end

    # Log a message to the default output with log level :error
    #
    # @param [String] message to log
    def self.error(message)
      log(message, :error)
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
