Given(/^that the app has launched$/) do
  wait_for_view('tabBarButton')
end

Then(/^I check status bar orientation$/) do
  expect(status_bar_orientation).to be_truthy
end

And(/^I can tell if the app is in portrait or landscape$/) do
  expect(portrait?).to be_truthy
  expect(landscape?).to be_falsey
end
