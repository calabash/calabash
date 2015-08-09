# Cucumber does not load env.rb when running a dry-run. As the pages inherit
# from Calabash::Page and assert that the scopes IOS and Android are defined,
# we should require calabash.

if ARGV.include?('--dry-run')
  require 'calabash/android'
  require 'calabash/ios'
end
