
Then(/^I use UIA to touch the text field$/) do
  wait_for_view("UITextField marked:'text'")
  uia_with_main_window("elements()['first page'].textFields()['text'].tap()")
end

Then(/^I use UIA to type "([^"]*)"$/) do |text|
  wait_for_keyboard
  uia_with_app("keyboard().typeString('#{text}')")
end

Then(/^I use UIA to touch the Done button on the keyboard$/) do
  wait_for_keyboard
  uia_with_app("keyboard().buttons()['Done'].tap()")
end
