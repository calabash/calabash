
Given(/^the iPhoneOnly app has launched$/) do
  app = Calabash::Application.default
  expect(app.identifier).to be == 'sh.calaba.iPhoneOnly'
  expect(runtime_details['app_id']).to be == 'sh.calaba.iPhoneOnly'
end

Then(/^the app will be in 1x mode$/) do
  # API is private so the real test is that we can touch the boxes
end

Then(/^I can tap the Moss box with UIA$/) do
  wait_for_view("view {accessibilityLabel LIKE 'Moss'}")
  uia_with_main_window("elements()['Moss'].tap()")
  wait_for_view("UILabel marked:'Moss'")
end

Then(/^we fail because gestures on emulated apps are broken$/) do
  raise 'Cannot perform gestures on iPhone apps emulated on iPads'
end

Then(/^I can touch all the boxes$/) do
  box_names = [
    'Cayenne', 'Asparagus', 'Clover', 'Midnight', 'Plum', 'Tin',
    'Mocha', 'Fern', 'Moss'
  ].shuffle

  box_names.each do |name|
    query = "view {accessibilityLabel LIKE '#{name}'}"
    tap(query)

    query = "UILabel marked:'#{name}'"
    wait_for_view(query)
  end
end
