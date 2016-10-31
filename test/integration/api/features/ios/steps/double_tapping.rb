Given(/^any visible view that reacts to double pressing$/) do
  cal.double_tap("UITabBarButton marked:'Gestures'")
  cal.tap({marked: 'tapping row'})
  sleep 2
end

When(/^Calabash is asked to double tap it$/) do
  cal.double_tap({id: 'left box'})
end

Then(/^it will perform a double tap gesture on the coordinates of the view$/) do
  cal.wait_for_view({marked: 'Double tap'})
end