Kernel.send(:alias_method, :require_prev, :require)

def require(path)
  #puts "Requiring #{path}"
  require_prev(path)
end

require 'calabash/android'

Calabash::Android::Build::Builder.new("/Users/tobiasroikjer/Desktop/Calabash-tests/general2/xtc_android_sample.apk").build