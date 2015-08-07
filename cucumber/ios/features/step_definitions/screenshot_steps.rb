module CalSmokeApp
  module Screenshots
    require 'fileutils'

    # To default location for screenshots is `./screenshots`.
    #
    # You can override this location by setting CAL_SCREENSHOT_PATH when you start
    # executing tests or opening a console.  At runtime, the screenshot
    # path is stored in the Calabash::Environment::SCREENSHOT_DIRECTORY
    # constant.
    #
    # On the Xamarin Test Cloud, we should not rely on CAL_SCREENSHOT_PATH
    # to be defined or to be set to directory we can write to.
    def screenshots_subdirectory
      if RunLoop::Environment.xtc?
        screenshot_dir = './screenshots'
      else
        screenshot_dir = Calabash::Environment::SCREENSHOT_DIRECTORY
      end

      unless File.exist?(screenshot_dir)
        FileUtils.mkdir_p(screenshot_dir)
      end

      File.join(screenshot_dir, 'scenario-screenshots')
    end
  end
end

World(CalSmokeApp::Screenshots)

And(/^I have cleared existing screenshots for this feature$/) do
  path = screenshots_subdirectory
  if File.exist?(path)
    FileUtils.rm_rf(path)
  end
end

And(/^the scenario\-screenshots subdirectory exists$/) do
  path = screenshots_subdirectory
  unless File.exist?(path)
    FileUtils.mkdir_p(path)
  end
end

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

