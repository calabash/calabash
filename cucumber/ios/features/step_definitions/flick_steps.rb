
When(/^I flick right on the screen \(swipe to go back\)$/) do
  wait_for_animations

  # todo Use flick screen right once we've figure out how to
  # settle the defaults
  # flick_screen_right
  flick('*', percent(0, 50), percent(75, 50))
end

