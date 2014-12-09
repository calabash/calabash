# @!visibility private
if Kernel.const_defined?(:CALABASH_BACKWARDS_COMPATIBILITY_SCRIPT_RUN)
  raise 'Calabash backwards compatibility script can only be run once'
end

# @!visibility private
Kernel.const_set(:CALABASH_BACKWARDS_COMPATIBILITY_SCRIPT_RUN, true)

# @!visibility private
# Fail if Calabash::Cucumber is already defined. If that is the case, we do not know what
# side effects we might cause.
if Object.const_defined?(:Calabash) && Object.const_get(:Calabash).const_defined?(:Cucumber)
  raise 'Calabash::Cucumber is already defined'
end

# @!visibility private
# Define Calabash and Calabash::IOS if they do not already exist. The existing code will
# then patch the modules instead of defining them from scratch
Object.const_set(:Calabash, Module.new) unless Object.const_defined?(:Calabash)
Object.const_get(:Calabash).const_set(:IOS, Module.new) unless Object.const_get(:Calabash).const_defined?(:IOS)

# @!visibility private
# All references to Calabash::Cucumber will now refer implicitly to Calabash::IOS
Object.const_get(:Calabash).const_set(:Cucumber, Object.const_get(:Calabash).const_get(:IOS))

# @!visibility private
# This whole thing is a hack. It will be removed eventually
def require_old(path)
  module_name = self.name.split('::')[1].downcase

  raise "Invalid module name #{module_name}" unless module_name == 'android' || module_name == 'ios'

  if module_name == 'android'
    $LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'old', 'android', 'ruby-gem', 'lib')
  elsif module_name == 'ios'
    $LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'old', 'ios', 'calabash-cucumber', 'lib')
  end

  require File.join(File.dirname(__FILE__), '..', 'old', module_name, path)

  $LOAD_PATH.shift
end


# @!visibility private
def require_old_android_bin
  require File.join(File.dirname(__FILE__), '..', 'old', 'android', 'ruby-gem', 'bin', 'calabash-android-console')
end

# @!visibility private
def require_old_ios_bin
  path = File.join(File.dirname(__FILE__), '..', 'old', 'ios', 'calabash-cucumber')
  require File.join(path, 'bin', 'calabash-ios-build')

  @features_dir = File.join(path, "features")
  @source_dir = File.join(path, 'features-skeleton')
  @script_dir = File.join(path, 'scripts')
  @framework_dir = File.join(path, 'staticlib')
end