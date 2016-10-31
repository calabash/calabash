Given(/^any visible view$/) do
  cal.tap("UITabBarButton marked:'Controls'")
  sleep 0.5
end

When(/^Calabash is asked to tap it$/) do
  @on = (cal.query({id: 'switch'}, :isOn).first == 1)
  cal.tap({id: 'switch'})
end

Then(/^it will perform a tap gesture on the coordinates of the view$/) do
  on = (cal.query({id: 'switch'}, :isOn).first == 1)

  if on == @on
    raise "Expected the Switch to have been clicked #{@on} is equal to #{on}"
  end
end
