Given(/^an editable view with text in it$/) do
  cal.tap("UITabBarButton marked:'Controls'")
  cal.query({marked: 'text'}, setText: 'Some text')
end

When(/^the user asks to clear the text of the view$/) do
  cal.clear_text_in({marked: 'text'})
end

And(/^the text is cleared using selection and the keyboard$/) do
  text = cal.wait_for_view({marked: 'text'})['text']

  if text != ''
    raise "Expected text to be empty, was '#{text}'"
  end
end