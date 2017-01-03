Given(/^(a view|any screen) that reacts to being pinched$/) do |arg|
  cal.double_tap("UITabBarButton marked:'Gestures'")
  cal_ios.wait_for_animations
  cal.tap({marked: 'Pinching'})
  cal.wait_for_view("* id:'box'")
  cal_ios.wait_for_animations
  cal.pinch_in({id: 'pinching page'})
end

When(/^Calabash is asked to pinch (out|in) on it$/) do |direction|
  @previous_frame = cal.query({id: 'box'}, :frame).first

  if direction == 'out'
    cal.pinch_out({id: 'pinching page'})
  elsif direction == 'in'
    cal.pinch_in({id: 'pinching page'})
  end
end

Then(/^it will perform a pinch gesture on the coordinates of (the view|the screen) heading (outwards|inwards)$/) do |arg, expected_direction|
  # On iOS, pinching *in* zooms *in*

  new_frame = cal.query({id: 'box'}, :frame).first

  if expected_direction == 'outwards'
    unless new_frame["Width"] < @previous_frame["Width"]
      raise "Expected to have zoomed in, the frame of the box was #{new_frame}, compared to previous #{@previous_frame}"
    end
  elsif expected_direction == 'inwards'
    unless new_frame["Width"] > @previous_frame["Width"]
      raise "Expected to have zoomed out, the frame of the box was #{new_frame}, compared to previous #{@previous_frame}"
    end
  end
end


When(/^Calabash is asked to pinch (out|in) on the screen$/) do |direction|
  @previous_frame = cal.query({id: 'box'}, :frame).first

  if direction == 'out'
    cal.pinch_screen_out
  elsif direction == 'in'
    cal.pinch_screen_in
  end
end
