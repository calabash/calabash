
Then(/^I can get the min and max values of the slider$/) do
  query = "UISlider marked:'slider'"
  wait_for_view(query)

  max = query(query, :maximumValue).first
  min = query(query, :minimumValue).first

  expect(max).to be == 10
  expect(min).to be == -10
end

And(/^I can set the value of the slider to (\d+)$/) do |value|
  query = "UISlider marked:'slider'"

  slider_set_value(query, value.to_i)

  value = query(query, :value).first
  expect(value).to be == value.to_i
end
