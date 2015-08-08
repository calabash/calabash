
Then(/^backgrounding the app for less than one second raises an error$/) do
  expect do
    send_app_to_background(0.5)
  end.to raise_error ArgumentError, /must be between 1 and 60/
end

And(/^backgrounding the app for more than sixty seconds raises an error$/) do
  expect do
    send_app_to_background(61)
  end.to raise_error ArgumentError, /must be between 1 and 60/
end

But(/^I can send the app to the background for (\d+) seconds?$/) do |seconds|
  send_app_to_background(seconds.to_i)
end
