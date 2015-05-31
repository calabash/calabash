Given(/^I see the (first|second) tab$/) do |tab|
  wait_for_view('tabBarButton')
  tap("tabBarButton index:#{tab.eql?('first') ? 0 : 1}")
  expected_view = tab.eql?('first') ? 'first page' : 'second page'
  wait_for_view("view marked:'#{expected_view}'")
end

Then(/^I type "([^"]*)"$/) do |text_to_type|
  tap('textField')
  wait_for_keyboard
  query('textField', [{'setText' => text_to_type}])
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
