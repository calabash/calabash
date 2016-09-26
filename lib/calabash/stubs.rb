# Stubs for Calabash. Used for example when running Cucumber's dry-run

# Page class
unless Object.const_defined?(:Calabash)
  Object.const_set(:Calabash, Module.new)
end

unless Calabash.const_defined?(:Page)
  Calabash.const_set(:Page, Class.new)
end

# Android module (used for pages)
unless Object.const_defined?(:Android)
  Object.const_set(:Android, Module.new)
end

# IOS module (used for pages)
unless Object.const_defined?(:IOS)
  Object.const_set(:IOS, Module.new)
end

