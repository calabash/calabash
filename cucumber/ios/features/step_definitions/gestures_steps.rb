module CalSmokeApp
  module WaitForGesture

    def wait_for_gesture(expected_text)
      query = "label marked:'last gesture'"

      message = "Timed out waiting for #{query} to have text '#{expected_text}'"

      wait_for(message) do
        result = query(query)

        !result.empty? && result.first['text'] == expected_text
      end
    end
  end
end

World(CalSmokeApp::WaitForGesture)

When(/^I tap a view that does not exist$/) do
  begin
    tap("view marked:'does not exist'")
  rescue Calabash::Wait::ViewNotFoundError => e
    @wait_view_not_found_error = e
  end
end

Then(/^a view-not-found wait error is raised$/) do
  expect(@wait_view_not_found_error).to be_an_instance_of Calabash::Wait::ViewNotFoundError
end

When(/^I double tap the box$/) do
  double_tap("view marked:'gestures box'")
end

Then(/^the gesture description changes to (double tap|long press)$/) do |type|
  if type == 'double tap'
    expected = 'Double tap'
  else
    expected = "Long press: #{@last_long_press_duration} seconds"
  end

  wait_for_gesture(expected)
end

When(/^I long press the box for (\d+) seconds?$/) do |duration|
  query = "view marked:'gestures box'"
  long_press(query, {:duration => duration.to_i})
  @last_long_press_duration = duration.to_i
end
