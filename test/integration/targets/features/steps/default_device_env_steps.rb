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
  def test_method_returning_target
    Calabash::Internal.with_current_target do |target|
      target
    end
  end
end

Given(/^an ENV that uniquely identifies the default device for (android|ios)$/) do |os|
  if os == 'android'
    stub_application_default_from_environment {:android_app}
    stub_default_serial {'MY-SERIAL'}
  elsif os == 'ios'
    stub_application_default_from_environment {:ios_app}
    stub_default_identifier_for_application {'MY-SERIAL'}
  end
end

When(/^calabash\/(android|ios) is required$/) do |os|
  require_calabash "calabash/#{os}"
end

Then(/^Calabash sets a default device-target using the ENV$/) do
  expect(Calabash::Internal.with_current_target {|target| target.device.identifier}).to eq('MY-SERIAL')
end

When(/^Calabash is asked to interact$/) do
  begin
    @target = cal.test_method_returning_target
  rescue => e
    @error = e
  end
end

Then(/^it selects a target with that device$/) do
  expect(@error).to be_nil
  expect(@target.device.identifier).to eq('MY-SERIAL')
end

Given(/^an ENV that does not uniquely identify the default device for (android|ios)$/) do |os|
  if os == 'android'
    stub_default_serial {raise 'Unable to set default device MY-MESSAGE'}
  elsif os == 'ios'
    stub_application_default_from_environment {:ios_app}
    stub_default_identifier_for_application {raise 'Unable to set default device MY-MESSAGE'}
  end
end

Then(/^Calabash does not set a default device-target using the ENV$/) do
  expect(Calabash::Internal.default_target_state.
      instance_variable_get(:@default_device_state)).to be_a(Calabash::TargetState::DefaultTargetState::State::Unknown)
end

Then(/^it fails stating why the default device target was not set$/) do
  expect(@target).to be_nil
  expect(@error.message).to eq('Could not set the default device-target automatically: Unable to set default device MY-MESSAGE')
end

Given(/^the user explicitly sets the default device$/) do
  pending
end