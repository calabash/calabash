Given(/^I see the (first|second|third) tab$/) do |tab|
  wait_for_view('tabBarButton')
  case tab
    when 'first'
      index = 0
    when 'second'
      index = 1
    when 'third'
      index = 2
  end
  tap("tabBarButton index:#{index}")
  expected_view = "#{tab} page"
  wait_for_view("view marked:'#{expected_view}'")
end

Given(/^the app has launched$/) do
  wait_for_view
end

And(/^I touch the text field$/) do
  tap('textField')
end
