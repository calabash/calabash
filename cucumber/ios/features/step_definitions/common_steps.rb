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

And(/^I touch the text field$/) do
  tap('textField')
end

When(/^I search for cell "([^"]*)" scrolling (up|down|left|right)$/) do |mark, direction|
  puts 'passed!'
end

When(/^I scroll (up|down|left|right) for (\d+) times$/) do |direction, times|
  puts 'passed!'
end

Then(/^I should see cell (\d+)$/) do |arg1|
  puts 'passed!'
end

Given(/^I see the cell (\d+)$/) do |arg1|
  puts 'passed!'
end
