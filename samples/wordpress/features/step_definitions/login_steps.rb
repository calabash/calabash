Given(/^I try to sign in using (invalid|valid) credentials$/) do |type|
  if type == 'valid'
    credentials = CREDENTIALS[:valid_user]
  elsif type == 'invalid'
    credentials = CREDENTIALS[:invalid_user]
  else
    raise "Unexpected credential type '#{type}'"
  end

  cal.page(LoginPage).login(credentials[:username], credentials[:password])
end

Then(/^I should not be logged in$/) do
  if cal.android?
    cal.page(LoginPage).await
  elsif cal.ios?
    cal.page(AlertPage).await
  end
end

And(/^I should see an error message$/) do
  if cal.android?
    cal.page(LoginPage).expect_login_error_message
  elsif cal.ios?
    cal.page(AlertPage).expect_login_error_message
  end
end

Given(/^I am on the login screen$/) do
  # start_app has just been called
  cal.page(LoginPage).await
end

Then(/^I should be able to add a self\-hosted site$/) do
  cal.page(LoginPage).enable_self_hosted_site
end

Then(/^I should be logged in$/) do
  cal.page(PostsPage).await
end

Given(/^I am signed in$/) do
  Login.login
end

Then(/^I should be able to sign out$/) do
  cal.page(PostsPage).sign_out
  cal.page(LoginPage).await
end