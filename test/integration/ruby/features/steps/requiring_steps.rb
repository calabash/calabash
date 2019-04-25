def require_calabash(to_require)
  $_cal_methods_load = true

  # Add Calabash Methods for testing
  if to_require == 'calabash/android'
    load File.join(File.dirname(__FILE__), '..', 'support', 'calabash_android_test_methods.rb')
  elsif to_require == 'calabash/ios'
    load File.join(File.dirname(__FILE__), '..', 'support', 'calabash_ios_test_methods.rb')
  end

  file = "lib/#{to_require}.rb"

  loaded_file = $LOADED_FEATURES.select {|f| f.end_with?(file)}.first

  reset_verbose = $VERBOSE
  $VERBOSE = nil

  if loaded_file
    load loaded_file
  else
    require to_require
  end

  $VERBOSE = reset_verbose

  $_cal_methods_load = false
end

Given(/^I have required "(.*)"$/) do |to_require|
  require_calabash to_require
end

When(/I require "(.*)"$/) do |to_require|
  require_calabash to_require
end

Then(/^I have access to the Calabash API and Calabash Android API$/) do
  expect(cal.test).to eq(:test)
  expect(cal_android.android_test).to eq(:android_test)
end

Then(/^I have access to the Calabash API and Calabash iOS API$/) do
  expect(cal.test).to eq(:test)
  expect(cal_ios.ios_test).to eq(:ios_test)
end

Then(/^I get an error as I cannot include both Calabash iOS and Calabash Android$/) do
  expect(@rescue_exception).to be_a(Calabash::RequiredBothPlatformsError)
end


When(/^I invoke a method from the Calabash API$/) do
  @result = cal.specific_implementation
end

Then(/^the (.*) specific implementation is called$/) do |os|
  expect(@result).to eq(:"#{os}_implementation")
end