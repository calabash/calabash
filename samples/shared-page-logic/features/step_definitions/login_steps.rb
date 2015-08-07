Given(/^I try to sign in using invalid credentials$/) do
  page(LoginPage).login('username', 'password')
end