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

When(/^I type "([^"]*)" character by character$/) do |string|
  string.each_char do |character|
    enter_text(character)
  end
end

And(/^I can dismiss the keyboard by touching the Done key$/) do
  tap_keyboard_action_key
  wait_for_no_keyboard
end

Given(/^I have entered some text in the text field$/) do
  wait_for_view('UITextField')
  query('UITextField', [setText:'some text'])
end

Then(/^I can clear the text field with setText:$/) do
  wait_for_view('UITextField')
  query('UITextField', [setText:''])
  expect(query('UITextField', :text).first).to be == ''
end

Then(/^I can clear the text field with the editing menu$/) do
  unless keyboard_visible?
    tap('UITextField')
    wait_for_keyboard
  end

  tap('UITextField')

  tap("UICalloutBarButton marked:'Select All'")

  tap("UICalloutBarButton marked:'Cut'")

  wait_for_no_view('UICalloutBarButton')

  text = query('UITextField', :text).first

  # Depending on the version, :text will be nil or ''
  unless text == '' || text == nil
    fail("Excepted text field to be empty, but found '#{text}'")
  end
end
