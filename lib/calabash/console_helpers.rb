require 'clipboard'

module Calabash

  # Helper methods for the Calabash console.
  module ConsoleHelpers

    # Outputs all visible elements as a tree.
    def tree
      ConsoleHelpers.dump(Device.default.dump)
      true
    end

    # List the visible element classes.
    def classes
      query("*").map{|e| e['class']}.uniq
    end

    # List the visible element ids.
    def ids
      query("*").map{|e| e['id']}.compact
    end

    # Copy all the commands entered in the current console session into the OS
    # Clipboard.
    def copy
      ConsoleHelpers.copy
      true
    end

    def clear
      ConsoleHelpers.clear
      true
    end

    # !@visibility private
    def self.save_old_readline_history
      file_name = IRB.conf[:HISTORY_FILE]

      if File.exist?(file_name)
        @@start_readline_history = File.readlines(file_name).map(&:chomp)
      end
    end

    # !@visibility private
    def self.extended(base)
      save_old_readline_history
    end

    # !@visibility private
    def self.copy
      commands = filter_commands(current_console_history)
      string = commands.join($INPUT_RECORD_SEPARATOR)
      Clipboard.copy(string)
    end

    # !@visibility private
    def self.clear
      if Gem.win_platform?
        system('cls')
      else
        system('clear')
      end

      @@start_readline_history = readline_history
    end

    # !@visibility private
    def self.current_console_history
      length = readline_history.length - @@start_readline_history.length

      readline_history.last(length)
    end

    FILTER_REGEX = Regexp.union(/\s*copy(\(|\z)/, /\s*tree(\(|\z)/,
                                /\s*flash(\(|\z)/, /\s*classes(\(|\z)/,
                                /\s*ids(\(|\z)/, /\s*start_app(\(|\z)/,
                                /\s*install_app(\(|\z)/,
                                /\s*ensure_app_installed(\(|\z)/,
                                /\s*uninstall_app(\(|\z)/,
                                /\s*clear_app(\(|\z)/,
                                /\s*stop_app(\(|\z)/)

    # !@visibility private
    def self.filter_commands(commands)
      commands.reject {|command| command =~ FILTER_REGEX}
    end

    # !@visibility private
    def self.readline_history
      Readline::HISTORY.to_a
    end

    # !@visibility private
    def self.dump(json_data)
      json_data['children'].each {|child| write_child(child)}
    end

    # !@visibility private
    def self.write_child(data, indentation=0)
      render(data, indentation)

      data['children'].each do |child|
        write_child(child, indentation+1)
      end
    end

    # !@visibility private
    def self.render(data, indentation)
      raise AbstractMethodError
    end

    # !@visibility private
    def self.output(string, indentation)
      (indentation*2).times {print " "}
      print "#{string}"
    end

    # !@visibility private
    def self.visible?(data)
      raise AbstractMethodError
    end
  end
end
