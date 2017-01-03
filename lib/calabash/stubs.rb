# Stubs for Calabash. Used for example when running Cucumber's dry-run

# The Calabash module
unless Object.const_defined?(:Calabash)
  Object.const_set(:Calabash, Module.new)
end

# Page class
unless Calabash.const_defined?(:Page)
  Calabash.const_set(:Page, Class.new)
end
