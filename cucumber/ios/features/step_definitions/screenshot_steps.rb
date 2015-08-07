require 'fileutils'

When(/^I take a screenshot with the default screenshot method$/) do
  @last_screenshot_path = screenshot
end

Then(/^the screenshot has a number appended to the name$/) do
  regex = /screenshots\/test_run_(\d+)\/screenshot_(\d+)\.png/
  expect(@last_screenshot_path[regex, 0]).to be_truthy
  expect(File.exists?(@last_screenshot_path)).to be_truthy
end

When(/^I take a screenshot and specify the name$/) do
  @last_screenshot_path = screenshot("my-name")
end

Then(/^the screenshot is saved with that name in the default location$/) do
  expect(File.exists?(@last_screenshot_path)).to be_truthy
end

When(/^I take a screenshot and specify an absolute path$/) do
  dir = File.expand_path('./screenshots/absolute')
  if File.exists?(dir)
    FileUtils.rm_r(dir)
  end

  path = File.join(dir, 'surprise.png')
  @last_screenshot_path = screenshot(path)
end

Then(/^the screenshot is created where I specified$/) do
  expect(File.exists?(@last_screenshot_path)).to be_truthy
end

When(/^I take a screenshot and specify a relative path$/) do
  dir = './screenshots/relative'

  if File.exists?(File.expand_path(dir))
    FileUtils.rm_r(File.expand_path(dir))
  end

  path = File.join(dir, 'surprise.png')
  @last_screenshot_path = screenshot(path)
end

