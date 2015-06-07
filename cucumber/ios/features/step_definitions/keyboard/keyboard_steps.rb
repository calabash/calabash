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

Then(/^I can clear the text field with the clear text button$/) do
  wait_for_view 'UITextField'

  clear_button_mode = query('UITextField', :clearButtonMode).first
  unless clear_button_mode == 3
    fail("Expected the text field clearButtonMode to be '3' but found '#{clear_button_mode}'")
  end

  text = query('UITextField', :text).first
  if text == '' || text == nil
      fail('Expected some text in the text field so the clear button would appear')
  end

  query_string = 'UITextField descendant button'
  wait_for_view query_string

  tap(query_string)

  text = query('UITextField', :text).first

  # Depending on the version, :text will be nil or ''
  unless text == '' || text == nil
    fail("Excepted text field to be empty, but found '#{text}'")
  end
end

And(/^the text field has "([^"]*)" in it$/) do |text|
  wait_for_view 'UITextField'
  query('UITextField', [{setText:text}])
end

And(/^the (default|ascii|numbers and punctuation|url|number|phone|name and phone|email|decimal|twitter|web search) (?:keyboard|pad) is showing$/) do |kb_type|
  qstr = 'UITextField'
  target = keyboard_type_from_step_argument kb_type
  ensure_keyboard_type(qstr, target)
  tap(qstr)
  wait_for_keyboard
end

And(/^realize my mistake and delete (\d+) characters? and replace with "([^"]*)"$/) do |num_taps, replacement|
  before = text_from_keyboard_first_responder
  num = num_taps.to_i

  num.times do
    tap_keyboard_delete_key
  end

  idx = (before.length - num) - 1
  expected = "#{before[0..idx]}#{replacement}"

  enter_text(replacement)

  actual = text_from_keyboard_first_responder

  unless actual.eql?(expected)
    screenshot_and_raise "expected '#{expected}' after tapping the delete key '#{num}' times but found '#{actual}'"
  end
end

Then(/^I text my friend a facepalm "([^"]*)"$/) do |text|
  wait_for_view 'UITextField'
  query('UITextField', [{setText:text}])
end

Then(/^I say, "([^"]*)"$/) { |_| }
Then(/^he said, "([^"]*)"$/) { |_| }
Then(/^I say, "54-36", that's my number$/) do
  wait_for_view 'UITextField'
  query('UITextField', [{setText:'54-36'}])
end
