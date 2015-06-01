Then(/^I wait for the keyboard$/) do
  wait_for_keyboard
end

Then(/^I type "([^"]*)"$/) do |text_to_type|
  enter_text(text_to_type)
end
