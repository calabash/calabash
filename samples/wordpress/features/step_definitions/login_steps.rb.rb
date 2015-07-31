Given(/^I try to sign in using (invalid|valid) credentials$/) do |type|
  if type == 'valid'
    credentials = CREDENTIALS[:valid_user]
  elsif type == 'invalid'
    credentials = CREDENTIALS[:invalid_user]
  else
    raise "Unexpected credential type '#{type}'"
  end

  page(LoginPage).login(credentials[:username], credentials[:password])
end

Then(/^I should not be logged in$/) do
  if android?
    page(LoginPage).await
  else
    page(AlertPage).await
  end
end

And(/^I should see an error message$/) do
  if android?
    page(LoginPage).expect_login_error_message
  else
    page(AlertPage).expect_login_error_message
  end
end

Given(/^I am on the login screen$/) do
  # start_app has just been called
  page(LoginPage).await
end

Then(/^I should be able to add a self\-hosted site$/) do
  page(LoginPage).enable_self_hosted_site
end

Then(/^I should be logged in$/) do
  page(PostsPage).await
end

Given(/^I am signed in$/) do
  Login.login
end

Then(/^I should be able to sign out$/) do
  page(PostsPage).sign_out
  page(LoginPage).await
end