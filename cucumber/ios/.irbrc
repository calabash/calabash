require 'irb/completion'
require 'irb/ext/save-history'

module Calabash
  module IRBRC
    def self.with_warn_suppressed(&block)
      warn_level = $VERBOSE
      begin
        $VERBOSE = nil
        block.call
      ensure
        $VERBOSE = warn_level
      end
    end

    def self.message_of_the_day
      motd = ["Let's get this done!", 'Ready to rumble.', 'Enjoy.', 'Remember to breathe.',
              'Take a deep breath.', "Isn't it time for a break?", 'Can I get you a coffee?',
              'What is a calabash anyway?', 'Smile! You are on camera!', 'Let op! Wild Rooster!',
              "Don't touch that button!", "I'm gonna take this to 11.", 'Console. Engaged.',
              'Your wish is my command.', 'This console session was created just for you.',
              'Den som jager to harer, får ingen.', 'Uti, non abuti.', 'Non Satis Scire',
              'Nullius in verba', 'Det ka æn jå væer ei jált']

      begin
        puts "Calabash #{Calabash::VERSION} says: '#{motd.shuffle.first}'"
      rescue NameError => _
        puts "Calabash says: '#{motd.shuffle.first}'"
      end
    end
  end
end

has_skipped_requires = false

Calabash::IRBRC.with_warn_suppressed do
  begin
    require 'calabash/ios'
    extend Calabash::IOS

    abp = File.join(File.dirname(__FILE__), '..', '..', 'spec', 'resources', 'ios', 'CalSmoke-cal.app')
    Calabash::Application.default = Calabash::IOS::Application.new(abp)

    identifier = Calabash::IOS::Device.default_identifier_for_application(Calabash::Application.default)
    server = Calabash::IOS::Server.default

    Calabash::Device.default = Calabash::IOS::Device.new(identifier, server)

    embed_lambda = lambda do |*_|
      Calabash::Logger.info 'Embed is not available in the console.'
    end

    Calabash.new_embed_method!(embed_lambda)
  rescue LoadError => _
    puts 'INFO: Skipping calabash dependency'
    has_skipped_requires = true
  end

  begin
    require 'awesome_print'
    AwesomePrint.irb!
  rescue LoadError => _
    puts 'INFO: Skipping awesome_print dependency'
    has_skipped_requires = true
  end

  begin
    require 'pry'
  rescue LoadError => _
    puts 'INFO: Skipping pry dependency'
    has_skipped_requires = true
  end

  begin
    require 'pry-nav'
  rescue LoadError => _
    puts 'INFO: Skipping pry-nav dependency'
    has_skipped_requires = true
  end
end


if has_skipped_requires
  puts 'INFO: Some requires have been skipped.'
  puts 'INFO: Run with bundle exec if you need these dependencies'
end

IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = '.irb-history'

ARGV.concat [ '--readline',
              '--prompt-mode',
              'simple']

Calabash::IRBRC.message_of_the_day
