
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
