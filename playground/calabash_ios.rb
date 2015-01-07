Kernel.send(:alias_method, :require_prev, :require)

def require(path)
  #puts "Requiring #{path}"
  require_prev(path)
end

require 'calabash/ios'


module Calabash
  module IOS
    VERSION="0.9.169"
  end
end

extend Calabash::IOS::Operations

calabash_stop_app
calabash_start_app_in_background
query = "* marked:'free'"
wait_for_element_exists(query)
touch(query)
puts "Client version: #{client_version}"
puts "Server version: #{server_version}"