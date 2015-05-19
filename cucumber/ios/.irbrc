begin
    require 'irb/completion'
    require 'irb/ext/save-history'
    require 'awesome_print'
    AwesomePrint.irb!

    ARGV.concat [ '--readline',
                  '--prompt-mode',
                  'simple']

    IRB.conf[:SAVE_HISTORY] = 100
    IRB.conf[:HISTORY_FILE] = '.irb-history'

    require 'calabash/ios'

    extend Calabash::IOS

    Calabash::Application.default = Calabash::IOS::Application.default_from_environment

    identifier = Calabash::IOS::Device.default_identifier_for_application(Calabash::Application.default)
    server = Calabash::IOS::Server.default

    Calabash::Device.default = Calabash::IOS::Device.new(identifier, server)

    embed_lambda = lambda do |*_|
      Calabash::Logger.info 'Embed is not available in the console.'
    end

    Calabash.new_embed_method!(embed_lambda)
rescue Exception => e
    puts 'Unable to start console:'
    puts "#{e.class}: #{e.message}"
    puts "#{e.backtrace.join("\n")}"
    exit(1)
end
