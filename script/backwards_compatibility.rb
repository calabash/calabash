if Kernel.const_defined?(:CALABASH_BACKWARDS_COMPATIBILITY_SCRIPT_RUN)
  raise 'Calabash backwards compatibility script can only be run once'
end

Kernel.const_set(:CALABASH_BACKWARDS_COMPATIBILITY_SCRIPT_RUN, true)

# Fail if Calabash::Cucumber is already defined. If that is the case, we do not know what
#   side effects we might cause.
if Object.const_defined?(:Calabash) && Object.const_get(:Calabash).const_defined?(:Cucumber)
  raise 'Calabash::Cucumber is already defined'
end

# Define Calabash and Calabash::IOS if they do not already exist. The existing code will
#   then patch the modules instead of defining them from scratch
Object.const_set(:Calabash, Module.new) unless Object.const_defined?(:Calabash)
Object.const_get(:Calabash).const_set(:IOS, Module.new) unless Object.const_get(:Calabash).const_defined?(:IOS)

# All references to Calabash::Cucumber will now refer implicitly to Calabash::IOS
Object.const_get(:Calabash).const_set(:Cucumber, Object.const_get(:Calabash).const_get(:IOS))