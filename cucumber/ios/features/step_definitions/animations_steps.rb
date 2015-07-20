Then(/^I wait for all animations to stop$/) do
  # Test for:  https://github.com/calabash/calabash-ios-server/pull/142
  # When checking for no animation, ignore animations with trivially short durations
  wait_for_none_animating(4)
end

And(/^I have started an animation that lasts (\d+) seconds$/) do |duration|
  @last_animation_duration = duration.to_i
  @last_animation_query = "view marked:'animated view'"

  wait_for_view(@last_animation_query)
  backdoor('animateOrangeViewOnDragAndDropController:', duration)
end

Then(/^I can wait for the animation to stop$/) do
  timeout = @last_animation_duration + 1

  wait_for_animations(@last_animation_query, timeout)
end

And(/^I start the network indicator for (\d+) seconds$/) do |duration|
  @last_animation_duration = duration.to_i
  backdoor('startNetworkIndicatorForNSeconds:', duration.to_i)
end

Then(/^I can wait for the indicator to stop$/) do
  timeout = @last_animation_duration + 1
  wait_for_no_network_indicator(timeout)
end

When(/^I pass an empty query to wait_for_animations$/) do
  begin
    wait_for_animations('')
  rescue ArgumentError => _
    @runtime_error_raised = true
  end
end

Then(/^the app should not crash$/) do
  query('*')
end

And(/^an error should be raised$/) do
  expect(@runtime_error_raised).to be == true
end
