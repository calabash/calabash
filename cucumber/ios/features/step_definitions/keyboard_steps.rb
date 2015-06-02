Then(/^I wait for the keyboard$/) do
  wait_for_keyboard
end

Then(/^I type "([^"]*)"$/) do |text_to_type|
  enter_text(text_to_type)
end

And(/^the text in the text field should be "([^"]*)"$/) do |arg|
  expect(text_from_keyboard_first_responder).to be == arg
end

And(/^the keyboard is visible$/) do
  expect(keyboard_visible?).to be_truthy
end

And(/^the docked keyboard is visible$/) do
  expect(docked_keyboard_visible?).to be_truthy
end

And(/^the undocked keyboard is not visible$/) do
  expect(undocked_keyboard_visible?).to be_falsey
end

And(/^the split keyboard is not visible$/) do
  expect(split_keyboard_visible?).to be_falsey
end
