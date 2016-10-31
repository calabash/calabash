require 'clipboard'

module Calabash

  # Methods you can use in the Calabash console to help you
  # interact with your app.
  module ConsoleHelpers
    # Reloads all required files that have git changes
    def reload_git_files
      files_to_reload =
          (`cd ../../../ && git status`.lines.grep(/modified/).map{|l| l.split(" ").last.gsub('../', '')} +
              `cd ../../../ && git ls-files --others --exclude-standard`.lines).map(&:chomp)

      $LOADED_FEATURES.each do |file|
        files_to_reload.each do |reload_name|
          if file.end_with?(reload_name)
            puts "LOADING #{file}"
            load file
            break
          end
        end
      end

      true
    end

    # Outputs all calabash methods
    def cal_methods
      c = Class.new(BasicObject) do
        include Calabash
      end

      ConsoleHelpers.puts_unbound_methods(c, 'cal.')
      true
    end

    # Outputs a calabash method
    def cal_method(method)
      c = Class.new(BasicObject) do
        include Calabash
      end

      ConsoleHelpers.puts_unbound_method(c, method.to_sym, 'cal.')
      true
    end

    # Outputs all calabash iOS methods
    def cal_ios_methods
      c = Class.new(BasicObject) do
        include Calabash::IOSInternal
      end

      ConsoleHelpers.puts_unbound_methods(c, 'cal_ios.')
      true
    end

    # Outputs a calabash Android method
    def cal_ios_method(method)
      c = Class.new(BasicObject) do
        include Calabash::IOSInternal
      end

      ConsoleHelpers.puts_unbound_method(c, method.to_sym, 'cal_ios.')
      true
    end

    # Outputs all calabash Android methods
    def cal_android_methods
      c = Class.new(BasicObject) do
        include Calabash::AndroidInternal
      end

      ConsoleHelpers.puts_unbound_methods(c, 'cal_android.')
      true
    end

    # Outputs a calabash Android method
    def cal_android_method(method)
      c = Class.new(BasicObject) do
        include Calabash::AndroidInternal
      end

      ConsoleHelpers.puts_unbound_method(c, method.to_sym, 'cal_android.')
      true
    end

    # Outputs all visible elements as a tree.
    def tree
      ConsoleHelpers.dump(Device.default.dump)
      true
    end

    # List the visible element classes.
    def classes
      cal.query("*").map{|e| e['class']}.uniq
    end

    # List the visible element ids.
    def ids
      cal.query("*").map{|e| e['id']}.compact
    end

    # Copy all the commands entered in the current console session into the OS
    # Clipboard.
    def copy
      ConsoleHelpers.copy
      true
    end

    # Clear the console history. Note that this also clears the contents
    # given to Calabash::ConsoleHelpers#copy.
    def clear
      ConsoleHelpers.clear
      true
    end

    # Puts a message of the day.
    # @!visibility private
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
      puts '#             =>  Useful Console Methods  <=              #'
      puts Color.cyan('>         ids => List all the visible ids.')
      puts Color.cyan('>     classes => List all the visible classes.')
      puts Color.cyan(">        tree => The app's visible view hierarchy.")
      puts Color.cyan('>        copy => Copy console commands to the Clipboard.')
      puts Color.cyan('>       clear => Clear the console.')
      puts Color.cyan('>     verbose => Turn debug logging on.')
      puts Color.cyan('>       quiet => Turn debug logging off.')
      puts Color.cyan('> cal_methods => Print all cross-platform Calabash methods.')
      puts Color.cyan('> cal_method(method) => Print all information about a Calabash method')

      if defined?(Calabash::AndroidInternal)
        puts ''
        puts 'Android specific'
        puts Color.cyan('> cal_android_methods => Print all Android-specific Calabash methods.')
        puts Color.cyan('> cal_android_method(method) => Print all information about an Android-specific Calabash method.')
      end

      if defined?(Calabash::IOSInternal)
        puts ''
        puts 'iOS specific'
        puts Color.cyan('> cal_ios_methods => Print all iOS-specific Calabash methods.')
        puts Color.cyan('> cal_ios_method(method) => Print all information about an ios-specific Calabash method.')
      end

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

    # @!visibility private
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

    # @!visibility private
    def self.puts_unbound_methods(clazz, prefix)
      (clazz.instance_methods - BasicObject.instance_methods).each do |method_sym|
        signature,description = method_signature(clazz.instance_method(method_sym))

        puts_method(signature, description, prefix)
      end
    end

    # @!visibility private
    def self.puts_unbound_method(clazz, method, prefix)
      signature,description = method_signature(clazz.instance_method(method), true)

      puts_method(signature, description, prefix)
    end

    # @!visibility private
    def self.puts_method(signature, description, prefix)
      if signature != nil
        puts Color.yellow(description)
        puts Color.blue("#{prefix}#{signature}")
        puts ''
      end
    end

    # @!visibility private
    def self.method_signature(method, full_description = false)
      file_name, line = method.source_location

      file = File.open(file_name, 'r')

      description = nil
      read_next_lines = false

      (line-1).times do
        line = file.gets.strip

        if line.start_with?('#')
          if line.length == 1 || line.start_with?("# @")
            read_next_lines = false
          end

          if description.nil?
            description = line[2..-1]
            read_next_lines = true
          elsif read_next_lines || full_description
            description = "#{description}\n#{line[2..-1]}"
          end
        else
          description = nil
        end
      end

      signature = file.gets.strip[4..-1]

      method_name = if signature.index('(')
                      signature[0,signature.index('(')]
                    else
                      signature
                    end

      # Remove alias'ed methods
      if method_name != method.name.to_s
        signature = nil
      end

      if description && description.start_with?("@!visibility private")
        signature = nil
      end

      [signature,description]
    end
  end
end
