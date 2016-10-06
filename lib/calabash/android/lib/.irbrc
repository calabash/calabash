require 'irb/completion'
require 'irb/ext/save-history'

IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = '.irb-history'

ARGV.concat [ '--readline',
              '--prompt-mode',
              'simple']

begin
  require 'pry'
  Pry.config.history.file = '.pry-history'
  require 'pry-nav'
rescue LoadError => _

end

begin
  require 'awesome_print'
  AwesomePrint.irb!
rescue LoadError => e
  msg = ["Caught a LoadError: could not load 'awesome_print'",
         "#{e}",
         '',
         'Use bundler (recommended) or uninstall awesome_print.',
         '',
         '# Use bundler (recommended)',
         '$ bundle update',
         '$ bundle exec calabash console [path to apk]',
         '',
         '# Uninstall',
         '$ gem update --system',
         '$ gem uninstall -Vax --force --no-abort-on-dependent awesome_print']
  puts msg
  exit(1)
end

begin
  require 'calabash/android'

  IRB.conf[:PROMPT][:CALABASH] = {
    :PROMPT_I => "calabash #{Calabash::VERSION}> ",
    :PROMPT_S => "%03n> ",
    :PROMPT_C => "%03n> ",
    :RETURN => "%s\n"
  }

  IRB.conf[:PROMPT_MODE] = :CALABASH

  extend Calabash::ConsoleHelpers

  Calabash::Android.setup_defaults!

  embed_lambda = lambda do |*_|
    Calabash::Logger.info 'Embed is not available in the console.'
    true
  end

  Calabash.new_embed_method!(embed_lambda)

  Calabash::Screenshot.screenshot_directory_prefix = 'console_'

  puts_console_details
  message_of_the_day
rescue Exception => e
  puts 'Unable to start console:'
  puts "#{e.class}: #{e.message}"
  puts "#{e.backtrace.join("\n")}"
  exit(1)
end
