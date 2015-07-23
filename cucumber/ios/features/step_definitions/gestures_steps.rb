
When(/^I tap a view that does not exist$/) do
  begin
    tap("view marked:'does not exist'")
  rescue Calabash::Wait::ViewNotFoundError => e
    @wait_view_not_found_error = e
    ap e
  end
end

Then(/^a view-not-found wait error is raised$/) do
  expect(@wait_view_not_found_error).to be_an_instance_of Calabash::Wait::ViewNotFoundError
end
