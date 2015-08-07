
And(/^I see the pinching page$/) do
  query = "view marked:'pinching row'"

  tap(query)

  query = "view marked:'pinching page'"
  wait_for_view(query)

  wait_for_animations
end

When(/^I pinch out on the box, it gets bigger$/) do
  query = "view marked:'box'"
  box = wait_for_view(query)

  original_height = box['rect']['height']
  original_width = box['rect']['width']

  pinch_out(query)

  box = query(query).first
  new_height = box['rect']['height']
  new_width = box['rect']['width']

  expect(new_height).to be > original_height
  expect(new_width).to be > original_width
end

When(/^I pinch in on the box, it gets smaller$/) do
  query = "view marked:'box'"
  box = wait_for_view(query)

  original_height = box['rect']['height']
  original_width = box['rect']['width']

  pinch_in(query)

  box = query(query).first
  new_height = box['rect']['height']
  new_width = box['rect']['width']

  expect(new_height).to be < original_height
  expect(new_width).to be < original_width
end

And(/^I can zoom in on the box$/) do
  query = "view marked:'box'"
  box = wait_for_view(query)

  original_height = box['rect']['height']
  original_width = box['rect']['width']

  pinch_to_zoom_in(query)

  box = query(query).first
  new_height = box['rect']['height']
  new_width = box['rect']['width']

  expect(new_height).to be > original_height
  expect(new_width).to be > original_width
end

And(/^I can zoom out on the box$/) do
  query = "view marked:'box'"
  box = wait_for_view(query)

  original_height = box['rect']['height']
  original_width = box['rect']['width']

  pinch_to_zoom_out(query)

  box = query(query).first
  new_height = box['rect']['height']
  new_width = box['rect']['width']

  expect(new_height).to be < original_height
  expect(new_width).to be < original_width
end

And(/^I see the map views page$/) do
  query = "view marked:'map views row'"

  tap(query)

  query = "view marked:'map'"
  wait_for_view(query)

  # Map can take long time to stablize
  sleep 1.0
  wait_for_animations
end

Then(/^I can zoom (out|in) on the map$/) do |in_out|
  query = "view marked:'map'"

  wait_for_view(query)

  region = query(query, :region)

  if in_out == 'out'
    pinch_to_zoom_out(query)
  else
    pinch_to_zoom_in(query)
  end

  # Map can take long time to stabilize.
  sleep 1.0
  wait_for_animations

  expect(query(query, :region)).not_to be == region
end

Then(/^I can zoom (out|in) on the screen$/) do |in_out|
  query = "view marked:'map'"

  wait_for_view(query)

  region = query(query, :region)

  if in_out == 'out'
    pinch_screen_to_zoom_out
  else
    pinch_screen_to_zoom_in
  end

  # Map can take long time to stabilize.
  sleep 1.0
  wait_for_animations

  expect(query(query, :region)).not_to be == region
end

Then(/^I can pinch (in|out) on the screen$/) do |in_out|
  query = "view marked:'map'"

  wait_for_view(query)

  region = query(query, :region)

  if in_out == 'out'
    pinch_screen_out
  else
    pinch_screen_in
  end

  # Map can take long time to stabilize.
  sleep 1.0
  wait_for_animations

  expect(query(query, :region)).not_to be == region
end

