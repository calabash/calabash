Kernel.send(:alias_method, :require_prev, :require)

def require(path)
  #puts "Requiring #{path}"
  require_prev(path)
end

require 'calabash/android'


module Calabash
  module Android
    VERSION="0.5.5"
  end
end
extend Calabash::Android::Operations

shutdown_test_server
start_test_server_in_background
touch "* text:'Web View'"
puts client_version
puts server_version