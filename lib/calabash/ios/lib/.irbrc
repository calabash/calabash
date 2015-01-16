require 'irb/completion'
require 'irb/ext/save-history'
require 'awesome_print'
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

include Calabash::IOS

Calabash::Logger.log_levels += [:debug] if Calabash::Environment.variable('CALABASH_DEBUG') == '1'

def embed(x,y=nil,z=nil)
  puts "Screenshot at #{x}"
end
