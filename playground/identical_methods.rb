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
ios_methods.map!{|method| Temp.method(method)}

require 'calabash/android'

class Temp2
  extend Calabash::Android::Operations
end

$stdout = File.new('/dev/null', 'w')
$stderr = File.new('/dev/null', 'w')
same = []
ni = []
different = []

android_methods = Temp2.methods - Object.methods
android_methods.select! {|method| !method.to_s.start_with?('_')}
android_methods.map!{|method| Temp2.method(method)}

common_method_names = ios_methods.map(&:name) & android_methods.map(&:name)

common_method_names.each do |method_name|
  ios_method = Temp.method(method_name.to_sym)
  android_method = Temp2.method(method_name.to_sym)

  ios_method_s = "#{ios_method.name} #{ios_method.parameters.map(&:last)}"
  android_method_s = "#{android_method.name} #{android_method.parameters.map(&:last)}"

  not_implemented = false

  begin
    args = []
    ios_method.parameters.length.times {args << nil}
    ios_method.call(*args)
  rescue => e
    not_implemented = true if e.message == 'Not yet implemented.' || e.message.downcase.include?('not implemented')
  end

  begin
    args = []
    android_method.parameters.length.times {args << nil}
    android_method.call(*args)
  rescue => e
    not_implemented = true if e.message == 'Not yet implemented.' || e.message.downcase.include?('not implemented')
  end

  if ios_method_s == android_method_s
    if not_implemented
      ni << "\e[33m#{ios_method_s}\e[0m"
    else
      same << "\e[32m#{ios_method_s}\e[0m"
    end
  else
    different << "\e[31m#{ios_method_s} - #{android_method_s}\e[0m"
  end
end

$stdout = STDOUT
$stderr = STDERR

puts "\e[35m\#\#\#\#Same\#\#\#\#\#\e[0m"
puts same.join("\n")

puts ''
puts "\e[35m\#\#\#\#Not implemented\#\#\#\#\#\e[0m"
puts ni.join("\n")

puts ''
puts "\e[35m\#\#\#\#Different\#\#\#\#\#\e[0m"
puts different.join("\n")

