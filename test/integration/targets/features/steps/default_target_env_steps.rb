Given(/^an ENV that uniquely identifies the default target for (.*)$/) do |os|
  if os == 'android'
    stub_application_default_from_environment {:default_application}
    stub_default_serial {'MY-SERIAL'}
  elsif os == 'ios'
    stub_application_default_from_environment {:default_application}
    stub_default_identifier_for_application {'MY-SERIAL'}
  end
end

Then(/^Calabash sets a default target using the ENV$/) do
  expect(Calabash::Internal.with_current_target {|target| target.application}).to eq(:default_application)
  expect(Calabash::Internal.with_current_target {|target| target.device.identifier}).to eq('MY-SERIAL')
end

Then(/^it selects that target$/) do
  expect(@target.device.identifier).to eq('MY-SERIAL')
  expect(@target.application).to eq(:default_application)
end

Given(/^an ENV that does not uniquely identify the default target for (.*)$/) do |os|
  if os == 'android'
    stub_application_default_from_environment {raise 'MY APP FAILURE'}
    stub_default_serial {'MY-SERIAL'}
  elsif os == 'ios'
    # iOS asks for the application first to obtain the default device, don't fail this call
    $not_first = false
    stub_application_default_from_environment do
      unless $not_first
        :app
        $not_first = true
      else
        raise 'MY APP FAILURE'
      end
    end
    stub_default_identifier_for_application {'MY-SERIAL'}
  end
end

Then(/^Calabash does not set a default target using the ENV$/) do

end

Then(/^it fails stating why the default device was not set$/) do
  expect(@error.message).to eq('Could not set the default target automatically: MY APP FAILURE')
end