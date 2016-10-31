Given(/^any visible view that reacts to long pressing$/) do
  cal.double_tap("UITabBarButton marked:'Gestures'")
  cal_ios.wait_for_animations
  cal.tap({marked: 'tapping row'})
  sleep 0.5
end

When(/^Calabash is asked to long press it$/) do
  cal.long_press({id: 'left box'})
end

Then(/^it will perform a long press gesture on the coordinates of the view$/) do
  cal.wait_for_view({marked: 'Long press: 1 seconds'})
end

When(/^Calabash is asked to long press it for 2 seconds$/) do
  cal.long_press({id: 'right box'}, duration: 2)
end

Then(/^it will perform a long press gesture on the coordinates of the view for 2 seconds$/) do
  cal.wait_for_view({marked: 'Long press: 2 seconds'})
end
