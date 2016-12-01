def require_calabash(to_require)
  $_cal_methods_load = true

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

module Calabash
  def test_method_returning_device
    Calabash::Internal.with_default_device do |device|
      device
    end
  end
end

Given(/^an ENV that uniquely identifies the default device for (android|ios)$/) do |os|
  if os == 'android'
    stub_default_serial {'MY-SERIAL'}
  elsif os == 'ios'
    Calabash::IOS::Application.default = :some_application
    stub_default_identifier_for_application {'MY-SERIAL'}
  end
end

When(/^calabash\/(android|ios) is required$/) do |os|
  require_calabash "calabash/#{os}"
end

Then(/^Calabash sets a default device using the ENV$/) do
  expect(Calabash::Internal.with_current_target {|target| target.device.identifier}).to eq('MY-SERIAL')
end

When(/^Calabash is asked to interact$/) do
  begin
    @device = cal.test_method_returning_device
  rescue => e
    @error = e
  end
end

Then(/^it selects that device$/) do
  expect(@error).to be_nil
  expect(@device.identifier).to eq('MY-SERIAL')
end

Given(/^an ENV that does not uniquely identify the default device for (android|ios)$/) do |os|
  if os == 'android'
    stub_default_serial {raise 'Unable to set default device MY-MESSAGE'}
  elsif os == 'ios'
    Calabash::IOS::Application.default = :some_application
    stub_default_identifier_for_application {raise 'Unable to set default device MY-MESSAGE'}
  end
end

Then(/^Calabash does not set a default device using the ENV$/) do
  expect(Calabash.default_device).to be_nil
end

Then(/^it does not fail$/) do

end

Then(/^it fails stating why the default device was not set$/) do
  expect(@device).to be_nil
  expect(@error.message).to eq('The default device is not set. Could not set default_device automatically: Unable to set default device MY-MESSAGE')
end

Given(/^the user explicitly sets the default device$/) do
  pending
end