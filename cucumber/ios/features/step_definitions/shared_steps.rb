Given(/^I see the (first|scrolls|special|tapping) tab$/) do |tab|
  wait_for_view('tabBarButton')
  case tab
  when 'first'
    index = 0
  when 'scrolls'
    index = 1
  when 'special'
    index = 2
  when 'tapping'
    index = 3
  end
  tap("tabBarButton index:#{index}")
  expected_view = "#{tab} page"
  wait_for_view("view marked:'#{expected_view}'")
end

Given(/^the app has launched$/) do
  wait_for_view('UITabBarButton')
end

And(/^I touch the text field$/) do
  tap('textField')
end
