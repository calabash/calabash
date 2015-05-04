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

    SIM=Calabash::IOS::SimulatorLauncher.new()

    extend Calabash::IOS

    Calabash::Android::Application.default = Calabash::Android::Application.default_from_environment

    Calabash::Logger.log_levels += [:debug] if Calabash::Environment::DEBUG

    Calabash.new_embed_method!(lambda {|*_| Calabash::Logger.info 'Embed is not available in the console.'})
rescue Exception => e
    puts 'Unable to start console:'
    puts "#{e.class}: #{e.message}"
    puts "#{e.backtrace.join("\n")}"
    exit(1)
end