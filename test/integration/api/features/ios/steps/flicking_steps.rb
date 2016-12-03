def extract_scroll(query)
  result = cal.query(query, :contentOffset).first

  {x: result['X'], y: result['Y']}
end

Given(/^any view that reacts to flicking down$/) do
  cal.tap("UITabBarButton marked:'Scrolls'")
  cal.tap({marked: 'Scroll views'})
  sleep 0.5
  cal.pan_up("UIScrollView")
end

When(/^Calabash is asked to flick down on it$/) do
  @before = extract_scroll("UIScrollView")
  cal.flick_down("UIScrollView")
  sleep 0.5
end

Then(/^it will perform a flick gesture on the coordinates of the view starting from the top going to the bottom$/) do
  now = extract_scroll("UIScrollView")

  unless @before[:x] == now[:x] && @before[:y] > now[:y]
    raise "Expected to have flicked down"
  end
end

Given(/^any view that reacts to flicking up$/) do
  cal.tap("UITabBarButton marked:'Scrolls'")
  cal.tap({marked: 'Scroll views'})
  sleep 0.5
end

When(/^Calabash is asked to flick up on it$/) do
  @before = extract_scroll("UIScrollView")
  cal.flick_up("UIScrollView")
  sleep 0.5
end

Then(/^it will perform a flick gesture on the coordinates of the view starting from the bottom going to the top$/) do
  now = extract_scroll("UIScrollView")

  unless @before[:x] == now[:x] && @before[:y] < now[:y]
    raise "Expected to have flicked up"
  end
end

Given(/^any view that reacts to flicking left$/) do
  cal.tap("UITabBarButton marked:'Scrolls'")
  cal.tap({marked: 'Scroll views'})
  sleep 0.5
end

When(/^Calabash is asked to flick left on it$/) do
  @before = extract_scroll("UIScrollView")
  cal.flick_left("UIScrollView")
  sleep 0.5
end

Then(/^it will perform a flick gesture on the coordinates of the view starting from the right going to the left$/) do
  now = extract_scroll("UIScrollView")

  unless @before[:x] < now[:x] && @before[:y] == now[:y]
    raise "Expected to have flicked left"
  end
end

Given(/^any view that reacts to flicking right/) do
  cal.tap("UITabBarButton marked:'Scrolls'")
  cal.tap({marked: 'Scroll views'})
  sleep 0.5
  cal.pan_left("UIScrollView")
end

When(/^Calabash is asked to flick right on it$/) do
  @before = extract_scroll("UIScrollView")
  cal.flick_right("UIScrollView")
  sleep 0.5
end

Then(/^it will perform a flick gesture on the coordinates of the view starting from the left going to the right$/) do
  now = extract_scroll("UIScrollView")

  unless @before[:x] > now[:x] && @before[:y] == now[:y]
    raise "Expected to have flicked right"
  end
end

When(/^Calabash is asked to flick left on it without being very slow$/) do
  # We detect the normal pan distance
  before = extract_scroll("UIScrollView")
  cal.pan_left("UIScrollView", duration: 3)
  after = extract_scroll("UIScrollView")

  @panning_distance = (before[:x] - after[:x]).abs

  # reset
  cal.pan_right("UIScrollView", duration: 3)

  @before = extract_scroll("UIScrollView")
  cal.flick_left("UIScrollView", duration: 0.1)
end

Then(/^Calabash will allow inertia in the gesture$/) do
  # sleep to allow the gesture to fully complete
  sleep 2

  after = extract_scroll("UIScrollView")
  distance = (@before[:x] - after[:x]).abs

  if distance <= @panning_distance + 10
    raise "Calabash limited the speed. Expected distance distance > #{@panning_distance + 10}, was #{distance}"
  end
end


Given(/^any screen that reacts to flicking down$/) do
  cal.tap("UITabBarButton marked:'Scrolls'")
  cal.tap({marked: 'Scroll views'})
  sleep 0.5
  cal.pan_screen_up
end

When(/^Calabash is asked to flick down on the screen$/) do
  @before = extract_scroll("UIScrollView")
  cal.flick_screen_down
  sleep 0.5
end

Then(/^it will perform a flick gesture on the coordinates of the screen starting from the top going to the bottom$/) do
  now = extract_scroll("UIScrollView")

  unless @before[:x] == now[:x] && @before[:y] > now[:y]
    raise "Expected to have flicked down"
  end
end

Given(/^any screen that reacts to flicking up$/) do
  cal.tap("UITabBarButton marked:'Scrolls'")
  cal.tap({marked: 'Scroll views'})
  sleep 0.5
end

When(/^Calabash is asked to flick up on the screen$/) do
  @before = extract_scroll("UIScrollView")
  cal.flick_screen_up
  sleep 0.5
end

Then(/^it will perform a flick gesture on the coordinates of the screen starting from the bottom going to the top$/) do
  now = extract_scroll("UIScrollView")

  unless @before[:x] == now[:x] && @before[:y] < now[:y]
    raise "Expected to have flicked up"
  end
end

Given(/^any screen that reacts to flicking left$/) do
  cal.tap("UITabBarButton marked:'Scrolls'")
  cal.tap({marked: 'Scroll views'})
  sleep 0.5
end

When(/^Calabash is asked to flick left on the screen$/) do
  @before = extract_scroll("UIScrollView")
  cal.flick_screen_left
  sleep 0.5
end

Then(/^it will perform a flick gesture on the coordinates of the screen starting from the right going to the left$/) do
  now = extract_scroll("UIScrollView")

  unless @before[:x] < now[:x] && @before[:y] == now[:y]
    raise "Expected to have flicked left"
  end
end

Given(/^any screen that reacts to flicking right/) do
  cal.tap("UITabBarButton marked:'Scrolls'")
  cal.tap({marked: 'Scroll views'})
  sleep 0.5
  cal.pan_screen_left
end

When(/^Calabash is asked to flick right on the screen$/) do
  @before = extract_scroll("UIScrollView")
  cal.flick_screen_right
  sleep 0.5
end

Then(/^it will perform a flick gesture on the coordinates of the screen starting from the left going to the right$/) do
  now = extract_scroll("UIScrollView")

  unless @before[:x] > now[:x] && @before[:y] == now[:y]
    raise "Expected to have flicked right"
  end
end