begin
    require 'irb/completion'
    require 'irb/ext/save-history'

    begin
        require 'awesome_print'
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

    AwesomePrint.irb!

    ARGV.concat [ '--readline',
                  '--prompt-mode',
                  'simple']

    # 50 entries in the list
    IRB.conf[:SAVE_HISTORY] = 50

    # Store results in home directory with specified file name
    IRB.conf[:HISTORY_FILE] = '.irb-history'

    require 'calabash/ios'

    extend Calabash::IOS
    extend Calabash::ConsoleHelpers

    Calabash::Application.default = Calabash::IOS::Application.default_from_environment

    identifier = Calabash::IOS::Device.default_identifier_for_application(Calabash::Application.default)
    server = Calabash::IOS::Server.default

    Calabash::Device.default = Calabash::IOS::Device.new(identifier, server)

    Calabash.new_embed_method!(lambda {|*_| Calabash::Logger.info 'Embed is not available in the console.'})
    Calabash::Screenshot.screenshot_directory_prefix = 'console_'
rescue Exception => e
    puts 'Unable to start console:'
    puts "#{e.class}: #{e.message}"
    puts "#{e.backtrace.join("\n")}"
    exit(1)
end
