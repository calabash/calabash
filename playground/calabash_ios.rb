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

my_methods = methods - Object.methods
my_methods.select! {|method| !method.to_s.start_with?('_')}
my_methods.map!{|method| method(method)}
puts my_methods.map{|method| "#{method.name} #{method.parameters.map &:last}"}.join("\n")