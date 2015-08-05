
When(/^I pan right on the screen \(swipe to go back\)$/) do
  wait_for_animations

  pan_screen_right

  wait_for_animations
end

Then(/^I go back to the Scrolls page$/) do
  query = "view marked:'scrolls page'"
  wait_for_view(query)
end

When(/^I pan to the cayenne box on the simulator$/) do
  if simulator?
    query = "UIScrollView marked:'scroll'"

    expect do
      pan(query, percent(80, 80), percent(10, 20))
    end.to raise_error RuntimeError,
    /Apple's public UIAutomation API `dragInsideWithOptions`/

  end
end

Then(/^I expect an error to be raised about dragInsideWithOptions$/) do
  # see step above
end

But(/^I can pan to the cayenne box on the device$/) do
  if physical_device?
    query = "UIScrollView marked:'scroll'"
    pan(query, percent(80, 80), percent(10, 20))
    wait_for_animations_in(query)
    wait_for_view("view marked:'cayenne'")
  end
end

And(/^I am on the panning gestures page$/) do
  wait_for_animations
  tap("view marked:'panning row'")

  query = "view marked:'panning page'"
  wait_for_view(query)
end

And(/^I clear the pan touch points$/) do
  wait_for_animations

  query = "view marked:'panning page'"
  wait_for_view(query)

  query(query, :clearTouchPoints)
end

Then(/^I can pan full-screen bottom to top$/) do
  wait_for_animations

  pan_screen_up

  wait_for_views("view marked:'begin'", "view marked:'end'")
end

And(/^I can pan full-screen top to bottom$/) do
  wait_for_animations

  pan_screen_down

  wait_for_views("view marked:'begin'", "view marked:'end'")
end

Then(/^I can pan full-screen left to right$/) do
  wait_for_animations

  pan_screen_right

  wait_for_views("view marked:'begin'", "view marked:'end'")
end

Then(/^I can pan full-screen right to left$/) do
  wait_for_animations

  pan_screen_left

  wait_for_views("view marked:'begin'", "view marked:'end'")
end
