Given(/^I have done a specific thing$/) do
  # Sample step definition
  # Example: (Given I am logged in)
  #  enter_text("* marked:'username'", USERNAME)
  #  enter_text("* marked:'password'", PASSWORD)
  #  touch("* marked:'login'")
  #  wait_for_view("* text:'Welcome #{USERNAME}'")

  # Remember: any Ruby is allowed in your step definitions
  did_something = true

  unless did_something
    fail 'Expected to have done something'
  end
end

When(/^I do something$/) do
  # Sample step definition
  # Example: When I create a new entry
  #  touch("* marked:'new_entry'")
  #  enter_text("* marked:'entry_title'", 'My Entry')
  #  touch("* marked:'submit'")
end

Then(/^something should happen$/) do
  # Sample step definition
  # Example: Then I should see the entry on my home page
  #  wait_for_view("* text:'My Entry'")
end
