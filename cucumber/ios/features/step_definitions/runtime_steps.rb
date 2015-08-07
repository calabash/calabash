
Then(/^I can ask if the device is a simulator or physical device$/) do
  expect([simulator?, physical_device?].any?).to be == true
end

And(/^I can ask if the device is an iPad, iPhone, or iPod$/) do
  expect([ipad?, iphone?, ipod?].any?).to be == true
end

And(/^I can ask if the device is in the iPhone family$/) do
  device_family_iphone?
end

And(/^I can ask if the app is an iPhone app emulated on an iPad$/) do
  iphone_app_emulated_on_ipad?
end

And(/^I can ask if the device is a (4in|3.5in) device$/) do |inches|
  iphone_4in?
  iphone_35in?
end

And(/^I can ask if the device is an iPhone 6 or iPhone 6\+$/) do
  iphone_6?
  iphone_6_plus?
end

And(/^I can ask for details about the device screen and app display details$/) do
  hash = app_screen_details
  expect(hash).to be_a_kind_of(Hash)
  expect(hash[:sample]).to be_truthy
  expect(hash[:scale]).to be_truthy
  expect(hash[:height]).to be_truthy
  expect(hash[:width]).to be_truthy
end

And(/^I can ask what version of iOS the device is running$/) do
  expect(ios_version).to be_a_kind_of(RunLoop::Version)
end

And(/^I can ask for the version of the Calabash iOS Server$/) do
  expect(server_version).to be_a_kind_of(RunLoop::Version)
end

And(/^I can ask specific questions about the iOS version$/) do
  expect([ios6?, ios7?, ios8?, ios9?].any?).to be == true
end

And(/^I can get version information about the app$/) do
  hash = app_version_details
  expect(hash).to be_a_kind_of(Hash)
  expect(hash[:bundle_version]).to be_truthy
  expect(hash[:short_version]).to be_truthy
end

And(/^I can get a full dump of the runtime attributes$/) do
  hash = runtime_details
  expect(hash).to be_a_kind_of(Hash)
end

