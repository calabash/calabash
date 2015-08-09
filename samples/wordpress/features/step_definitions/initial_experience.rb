Given(/^I have just started the application$/) do
  # start_app has just been called
end

Then(/^I should arrive at the login screen$/) do
  page(LoginPage).await(message: 'Expected to arrive at login page')
end

Given(/^I am on the first screen$/) do
  # start_app has just been called
end

And(/^I choose to get more information$/) do
  page(LoginPage).more_info
end

Then(/^I am taking to the information screen$/) do
  page(InfoPage).await(message: 'Expected to arrive at login page')
end


When(/^I go back from the help screen$/) do
  page(InfoPage).go_back_to_login_page
end

Then(/^I should be back on the login screen$/) do
  page(LoginPage).await(message: 'Expected to arrive at login page')
end