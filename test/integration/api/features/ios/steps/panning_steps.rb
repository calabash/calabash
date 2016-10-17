def extract_scroll(query)
  result = cal.query(query, :contentOffset).first

  {x: result['X'], y: result['Y']}
end

Given(/^any view that reacts to panning down$/) do
  cal.tap("UITabBarButton marked:'Scrolls'")
  cal.tap({marked: 'Scroll views'})
  sleep 0.5
  cal.pan_up("UIScrollView")
end

When(/^Calabash is asked to pan down on it$/) do
  @before = extract_scroll("UIScrollView")
  cal.pan_down("UIScrollView")
  sleep 0.5
end

Then(/^it will perform a pan gesture on the coordinates of the view starting from the top going to the bottom$/) do
  now = extract_scroll("UIScrollView")

  unless @before[:x] == now[:x] && @before[:y] > now[:y]
    raise "Expected to have panned down"
  end
end

Given(/^any view that reacts to panning up$/) do
  cal.tap("UITabBarButton marked:'Scrolls'")
  cal.tap({marked: 'Scroll views'})
  sleep 0.5
end

When(/^Calabash is asked to pan up on it$/) do
  @before = extract_scroll("UIScrollView")
  cal.pan_up("UIScrollView")
  sleep 0.5
end

Then(/^it will perform a pan gesture on the coordinates of the view starting from the bottom going to the top$/) do
  now = extract_scroll("UIScrollView")

  unless @before[:x] == now[:x] && @before[:y] < now[:y]
    raise "Expected to have panned up"
  end
end

Given(/^any view that reacts to panning left$/) do
  cal.tap("UITabBarButton marked:'Scrolls'")
  cal.tap({marked: 'Scroll views'})
  sleep 0.5
end

When(/^Calabash is asked to pan left on it$/) do
  @before = extract_scroll("UIScrollView")
  cal.pan_left("UIScrollView")
  sleep 0.5
end

Then(/^it will perform a pan gesture on the coordinates of the view starting from the right going to the left$/) do
  now = extract_scroll("UIScrollView")

  unless @before[:x] < now[:x] && @before[:y] == now[:y]
    raise "Expected to have panned left"
  end
end

Given(/^any view that reacts to panning right/) do
  cal.tap("UITabBarButton marked:'Scrolls'")
  cal.tap({marked: 'Scroll views'})
  sleep 0.5
  cal.pan_left("UIScrollView")
end

When(/^Calabash is asked to pan right on it$/) do
  @before = extract_scroll("UIScrollView")
  cal.pan_right("UIScrollView")
  sleep 0.5
end

Then(/^it will perform a pan gesture on the coordinates of the view starting from the left going to the right$/) do
  now = extract_scroll("UIScrollView")

  unless @before[:x] > now[:x] && @before[:y] == now[:y]
    raise "Expected to have panned right"
  end
end

When(/^Calabash is asked to pan left on it very fast$/) do
  # We detect the normal pan distance
  before = extract_scroll("UIScrollView")
  cal.pan_left("UIScrollView", duration: 3)
  after = extract_scroll("UIScrollView")

  @normal_distance = before[:x] - after[:x]

  # reset
  cal.pan_right("UIScrollView", duration: 3)

  @before = extract_scroll("UIScrollView")
  cal.pan_left("UIScrollView", duration: 0.1)
end

Then(/^Calabash will limit the speed to ensure the pan is not a flick$/) do
  after = extract_scroll("UIScrollView")
  distance = @before[:x] - after[:x]

  if (distance - @normal_distance).abs > 1
    raise "Calabash did not limit the speed. Expected distance #{@normal_distance}, was #{distance}"
  end
end


Given(/^any screen that reacts to panning down$/) do
  cal.tap("UITabBarButton marked:'Scrolls'")
  cal.tap({marked: 'Scroll views'})
  sleep 0.5
  cal.pan_screen_up
end

When(/^Calabash is asked to pan down on the screen$/) do
  @before = extract_scroll("UIScrollView")
  cal.pan_screen_down
  sleep 0.5
end

Then(/^it will perform a pan gesture on the coordinates of the screen starting from the top going to the bottom$/) do
  now = extract_scroll("UIScrollView")

  unless @before[:x] == now[:x] && @before[:y] > now[:y]
    raise "Expected to have panned down"
  end
end

Given(/^any screen that reacts to panning up$/) do
  cal.tap("UITabBarButton marked:'Scrolls'")
  cal.tap({marked: 'Scroll views'})
  sleep 0.5
end

When(/^Calabash is asked to pan up on the screen$/) do
  @before = extract_scroll("UIScrollView")
  cal.pan_screen_up
  sleep 0.5
end

Then(/^it will perform a pan gesture on the coordinates of the screen starting from the bottom going to the top$/) do
  now = extract_scroll("UIScrollView")

  unless @before[:x] == now[:x] && @before[:y] < now[:y]
    raise "Expected to have panned up"
  end
end

Given(/^any screen that reacts to panning left$/) do
  cal.tap("UITabBarButton marked:'Scrolls'")
  cal.tap({marked: 'Scroll views'})
  sleep 0.5
end

When(/^Calabash is asked to pan left on the screen$/) do
  @before = extract_scroll("UIScrollView")
  cal.pan_screen_left
  sleep 0.5
end

Then(/^it will perform a pan gesture on the coordinates of the screen starting from the right going to the left$/) do
  now = extract_scroll("UIScrollView")

  unless @before[:x] < now[:x] && @before[:y] == now[:y]
    raise "Expected to have panned left"
  end
end

Given(/^any screen that reacts to panning right/) do
  cal.tap("UITabBarButton marked:'Scrolls'")
  cal.tap({marked: 'Scroll views'})
  sleep 0.5
  cal.pan_screen_left
end

When(/^Calabash is asked to pan right on the screen$/) do
  @before = extract_scroll("UIScrollView")
  cal.pan_screen_right
  sleep 0.5
end

Then(/^it will perform a pan gesture on the coordinates of the screen starting from the left going to the right$/) do
  now = extract_scroll("UIScrollView")

  unless @before[:x] > now[:x] && @before[:y] == now[:y]
    raise "Expected to have panned right"
  end
end

Given(/^a view that reacts to being panned$/) do
  cal.tap("UITabBarButton marked:'Special'")

  # Reset the color
  cal.tap("UIImageView marked:'blue'")
end

When(/^Calabash is asked to pan between it and another view$/) do
  cal.pan_between("UIImageView marked:'red'", "* marked:'right well'")
end

Then(/^it will perform a pan gesture between the views using their coordinates$/) do
  color = cal.query("* marked:'right well'", :backgroundColor).first

  unless color["red"] > color["blue"] && color["red"] > color["green"]
    raise "Expected right well to be red, was #{color}"
  end
end