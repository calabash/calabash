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

class Temp
  extend Calabash::IOS::Operations
end

ios_methods = Temp.methods - Object.methods
ios_methods.select! {|method| !method.to_s.start_with?('_')}
ios_methods.select! {|method| !method.to_s.start_with?('uia')}
ios_methods.map!{|method| Temp.method(method)}

require 'calabash/android'

class Temp2
  extend Calabash::Android::Operations
end

$stdout = File.new('/dev/null', 'w')
$stderr = File.new('/dev/null', 'w')
ios = []
android = []

android_methods = Temp2.methods - Object.methods
android_methods.select! {|method| !method.to_s.start_with?('_')}
android_methods.map!{|method| Temp2.method(method)}

(ios_methods.map(&:name) - android_methods.map(&:name)).each do |method_name|
  method = Temp.method(method_name.to_sym)
  method_s = "#{method.name} #{method.parameters.map(&:last)}"

  not_implemented = false

  ios << "#{'(ni) ' if not_implemented}#{method_s}"
end


(android_methods.map(&:name) - ios_methods.map(&:name)).each do |method_name|
  method = Temp2.method(method_name.to_sym)
  method_s = "#{method.name} #{method.parameters.map(&:last)}"

  not_implemented = false

  begin
    args = []
    method.parameters.length.times {args << nil}
    method.call(*args)
  rescue => e
    not_implemented = true if e.message == 'Not yet implemented.' || e.message.downcase.include?('not implemented')
  end

  android << "#{'(ni) ' if not_implemented}#{method_s}"
end



$stdout = STDOUT
$stderr = STDERR

puts "\e[35m\#\#\#\#iOS (excluding uia)\#\#\#\#\#\e[0m"
puts ios.join("\n")

puts ''
puts ''
puts "\e[35m\#\#\#\#Android\#\#\#\#\#\e[0m"
puts android.join("\n")
