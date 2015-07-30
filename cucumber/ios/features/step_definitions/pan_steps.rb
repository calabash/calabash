
When(/^I pan left on the screen$/) do
  to = percent(0, 50)
  from = percent(75, 50)
  pan('*', to, from)
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
