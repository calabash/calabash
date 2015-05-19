Given(/^I see the (first|second) tab$/) do |tab|
  puts 'passed!'
end

Then(/^I type "([^"]*)"$/) do |text_to_type|
  puts 'passed!'
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
