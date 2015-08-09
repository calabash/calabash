
Then(/^I can flash the buttons$/) do
  views = flash('UIButton')
  expect(views.length).to be == 2
end

And(/^I can flash the labels in the tab bar$/) do
  views = flash("UITabBar descendant UITabBarButton descendant label")
  expect(views.length).to be == 5
end

When(/^the flash query matches no views$/) do
  @flash_results = flash("view marked:'some view that does not exist'")
end

Then(/^flash returns an empty array$/) do
  expect(@flash_results.empty?).to be == true
end
