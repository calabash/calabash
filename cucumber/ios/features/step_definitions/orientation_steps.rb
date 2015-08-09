
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

Then(/^I can rotate to landscape$/) do
  expect(set_orientation_landscape).to be == 'right'
end

And(/^I can rotate to portrait$/) do
  expect(set_orientation_portrait).to be == 'down'
end

And(/^the view controller (?:does|does not) support rotation$/) do
  # documentation step
end

When(/^I rotate (left|right)$/) do |direction|
  @orientation_before_rotation = status_bar_orientation
  if direction == 'left'
    rotate_device_left
  else
    rotate_device_right
  end
end

Then(/^no rotation occurred$/) do
  expect(status_bar_orientation).to be == @orientation_before_rotation
end

Then(/^a rotation occurred$/) do
  expect(status_bar_orientation).not_to be == @orientation_before_rotation
end

Then(/^I rotate so the home button is on the (right|left|top|bottom)$/) do |position|
  actual = rotate_home_button_to(position)

  expected = position
  expected = 'up' if position == 'top'
  expected = 'down' if position == 'bottom'

  expect(actual).to be == expected
end
