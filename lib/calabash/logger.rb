module Calabash
  class Logger
    def initialize(output=nil)
      @output = output || STDOUT.dup
    end

    # Log a message
    #
    # @param [String] message to log
    def log(message)
      @output.write(message)
    end

    # Log a message to the default output
    #
    # @param [String] message to log
    def self.log(message)
      Logger.new.log(message)
    end
  end
end