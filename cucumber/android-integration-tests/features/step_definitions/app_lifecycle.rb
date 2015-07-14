require 'fileutils'

Given(/^I have not installed any apps on the device$/) do

end

When(/^I install "([^"]*)"$/) do |application_identifier|
  file = "#{application_identifier}.apk"

  begin
    FileUtils.touch(file)
    application = Calabash::Android::Application.new(file, nil, identifier: application_identifier)
    install_app(application)
  ensure
    if File.exist?(file)
      File.delete(file)
    end
  end
end

Then(/^"([^"]*)" should be installed$/) do |application_identifier|
  unless Calabash::Device.default.send(:app_installed?, application_identifier)
    raise "Application is not installed!"
  end
end

When(/^I uninstall "([^"]*)"$/) do |application_identifier|
  file = "#{application_identifier}.apk"

  begin
    FileUtils.touch(file)
    application = Calabash::Android::Application.new(file, nil, identifier: application_identifier)
    uninstall_app(application)
  ensure
    if File.exist?(file)
      File.delete(file)
    end
  end
end

Then(/^"([^"]*)" should not be installed$/) do |application_identifier|
  if Calabash::Device.default.send(:app_installed?, application_identifier)
    raise "Application is installed!"
  end
end

When(/^I install "([^"]*)" again$/) do |application_identifier|
  file = "#{application_identifier}.apk"

  begin
    FileUtils.touch(file)
    application = Calabash::Android::Application.new(file, nil, identifier: application_identifier)
    install_app(application)
  ensure
    if File.exist?(file)
      File.delete(file)
    end
  end
end

Then(/^"([^"]*)" should be uninstalled and installed$/) do |application_identifier|
  history = Calabash::Device.default.adb.shell("LIST_HISTORY #{application_identifier}")
                .lines.map(&:chomp).map(&:to_sym)

  if history != [:installed, :uninstalled, :installed]
    raise "Expected a different history (#{history})"
  end
end

When(/^I ensure "([^"]*)" is installed$/) do |application_identifier|
  file = "#{application_identifier}.apk"

  begin
    FileUtils.touch(file)
    application = Calabash::Android::Application.new(file, nil, identifier: application_identifier)
    ensure_app_installed(application)
  ensure
    if File.exist?(file)
      File.delete(file)
    end
  end
end

When(/^I ensure "([^"]*)" is installed again$/) do |application_identifier|
  file = "#{application_identifier}.apk"

  begin
    FileUtils.touch(file)
    application = Calabash::Android::Application.new(file, nil, identifier: application_identifier)
    ensure_app_installed(application)
  ensure
    if File.exist?(file)
      File.delete(file)
    end
  end
end

Then(/^"([^"]*)" should not have been uninstalled$/) do |application_identifier|
  history = Calabash::Device.default.adb.shell("LIST_HISTORY #{application_identifier}")
                .lines.map(&:chomp).map(&:to_sym)

  if history != [:installed]
    raise "Expected a different history (#{history})"
  end
end