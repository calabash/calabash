Given(/^an editable view$/) do
  cal.tap("UITabBarButton marked:'Controls'")
  cal.query({marked: 'text'}, setText: '')
end

When(/^the user asks to enter text$/) do
  @expected_text = "Input1234 And Input1234"
  cal.enter_text_in({marked: 'text'}, @expected_text)
end

Then(/^the view is focused by tapping it$/) do
  # We don't actually test for this
end

And(/^text is entered using the keyboard$/) do
  text = cal.wait_for_view({marked: 'text'})['text']

  if text != @expected_text
    raise "Expected text to be '#{@expected_text}', was #{text}"
  end
end