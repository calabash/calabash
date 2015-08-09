def force_require(name)
  previous = $LOADED_FEATURES.find {|path| path =~ /#{name}\.rb\z/}

  if previous
    load previous
  else
    require name
  end
end

Given(/^no devices are visible$/) do
  Calabash::Android::ADB.command('KILL-DEVICES')
end

When(/^I ask for the default serial$/) do
  begin
    @last_error = nil
    @default_serial = nil
    @default_serial = Calabash::Android::Device.default_serial
  rescue => e
    @last_error = e
  end
end

Then(/^Calabash should fail, telling me no devices are available$/) do
  if @last_error.message != 'No devices visible on adb. Ensure a device is visible in `adb devices`'
    raise "Unexpected message '#{@last_error.message}'"
  end
end

Given(/^two devices, "([\w\-]*)" and "([\w\-]*)", are visible$/) do |identifier_a, identifier_b|
  Calabash::Android::ADB.command('ADD-DEVICE', identifier_a)
  Calabash::Android::ADB.command('ADD-DEVICE', identifier_b)
end

Then(/^Calabash should fail, telling me more than one device is available$/) do
  if @last_error.message != 'More than one device connected. Use CAL_DEVICE_ID to select serial'
    raise "Unexpected message '#{@last_error.message}'"
  end
end

Given(/^one device, "([\w\-]*)", is visible$/) do |identifier|
  Calabash::Android::ADB.command('ADD-DEVICE', identifier)
end

Then(/^Calabash should not fail and "([\w\-]*)" should be given as the default serial$/) do |identifier|
  unless @last_error.nil?
    @last_error.backtrace.each do |l|
      p l
    end
    raise "Did not expect to get an error! #{@last_error}"
  end

  unless @default_serial == identifier
    raise "Unexpected identifier '#{@default_serial}'"
  end
end

And(/^I have set the default identifier to "([\w\-]*)"$/) do |identifier|
  Calabash::Environment.set_variable!('CAL_DEVICE_ID', identifier)

  Calabash::Environment.constants(false).each do |const|
    Calabash::Environment.send(:remove_const, const)
  end

  force_require('calabash/environment')
end


Then(/^Calabash should fail, telling me the given identifier, "([\w\-]*)", is not visible$/) do |identifier|
  if @last_error.message != "A device with the serial '#{identifier}' is not visible on adb"
    raise "Unexpected message '#{@last_error.message}'"
  end
end
