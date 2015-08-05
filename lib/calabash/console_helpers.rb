require 'clipboard'

module Calabash

  # Methods you can use in the Calabash console to help you
  # interact with your app.
  # @!visibility private
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

    # Clear the console.
    def clear
      ConsoleHelpers.clear
      true
    end

    # Flashes any views matching `query`.
    #
    # @param [String, Symbol, Calabash::Query] query The query to match the
    #  view(s)
    def flash(query)
      Calabash::Device.default.map_route(Query.new(query), :flash)
    end

    # Puts a message of the day.
    def message_of_the_day
      messages = [
            "Let's get this done!",
            'Ready to rumble.',
            'Enjoy.',
            'Remember to breathe.',
            'Take a deep breath.',
            "Isn't it time for a break?",
            'Can I get you a coffee?',
            'What is a calabash anyway?',
            'Smile! You are on camera!',
            'Let op! Wild Rooster!',
            "Don't touch that button!",
            "I'm gonna take this to 11.",
            'Console. Engaged.',
            'Your wish is my command.',
            'This console session was created just for you.',
            'Den som jager to harer, får ingen.',
            'Uti, non abuti.',
            'Non Satis Scire',
            'Nullius in verba',
            'Det ka æn jå væer ei jált'
      ]

      puts Color.green("Calabash #{Calabash::VERSION} says: '#{messages.shuffle.first}'")
    end

    # Turn on debug logging.
    def verbose
      if Calabash::Logger.log_levels.include?(:debug)
        puts Color.blue('Debug logging is already turned on.')
      else
        Calabash::Logger.log_levels << :debug
        puts Color.blue('Turned on debug logging.')
      end

      true
    end

    # Turn off debug logging.
    def quiet
      if Calabash::Logger.log_levels.include?(:debug)
        puts Color.blue('Turned off debug logging.')
        Calabash::Logger.log_levels.delete(:debug)
      else
        puts Color.blue('Debug logging is already turned off.')
      end

      true
    end

    # @!visibility private
    def puts_console_details
      puts ''
      puts Color.blue('#             =>  Useful Methods  <=              #')
      puts Color.cyan('>     ids => List all the visible ids.')
      puts Color.cyan('> classes => List all the visible classes.')
      puts Color.cyan(">    tree => The app's visible view hierarchy.")
      puts Color.cyan('>    copy => Copy console commands to the Clipboard.')
      puts Color.cyan('>   clear => Clear the console.')
      puts Color.cyan('> verbose => Turn debug logging on.')
      puts Color.cyan('>   quiet => Turn debug logging off.')
      puts ''
    end

    # @!visibility private
    def self.save_old_readline_history
      file_name = IRB.conf[:HISTORY_FILE]

      if File.exist?(file_name)
        @@start_readline_history = File.readlines(file_name).map(&:chomp)
      end
    end

    # @!visibility private
    def self.extended(base)
      save_old_readline_history
    end

    # @!visibility private
    def self.copy
      commands = filter_commands(current_console_history)
      string = commands.join($INPUT_RECORD_SEPARATOR)
      Clipboard.copy(string)
    end

    # @!visibility private
    def self.clear
      if Gem.win_platform?
        system('cls')
      else
        system('clear')
      end

      @@start_readline_history = readline_history
    end

    # @!visibility private
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

    # @!visibility private
    def self.filter_commands(commands)
      commands.reject {|command| command =~ FILTER_REGEX}
    end

    # @!visibility private
    def self.readline_history
      Readline::HISTORY.to_a
    end

    # @!visibility private
    def self.dump(json_data)
      json_data['children'].each {|child| write_child(child)}
    end

    # @!visibility private
    def self.write_child(data, indentation=0)
      render(data, indentation)

      data['children'].each do |child|
        write_child(child, indentation+1)
      end
    end

    # @!visibility private
    def self.render(data, indentation)
      raise AbstractMethodError
    end

    # @!visibility private
    def self.output(string, indentation)
      (indentation*2).times {print " "}
      print "#{string}"
    end

    # @!visibility private
    def self.visible?(data)
      raise AbstractMethodError
    end
  end
end
