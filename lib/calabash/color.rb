module Calabash
  # @!visibility private
  module Color
    def self.colorize(string, color)
      "\e[#{color}m#{string}\e[0m"
    end

    def self.red(string)
      colorize(string, 31)
    end

    def self.green(string)
      colorize(string, 32)
    end

    def self.yellow(string)
      colorize(string, 33)
    end

    def self.blue(string)
      colorize(string, 34)
    end

    def self.magenta(string)
      colorize(string, 35)
    end

    def self.cyan(string)
      colorize(string, 36)
    end
  end
end
