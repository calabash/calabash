Kernel.send(:alias_method, :require_prev, :require)

def require(path)
  #puts "Requiring #{path}"
  require_prev(path)
end

require 'calabash'
require 'calabash/ios'


module Calabash
  module IOS
    VERSION="0.9.169"
  end
end
extend Calabash::IOS::Operations

shutdown_test_server
start_test_server_in_background
touch "* text:'Web View'"