module CalSmokeApp
  module Scroll
    def scroll_to(query, direction, visible_block)
      count = 0
      loop do
        break if visible_block.call || count == 3
        scroll(query, direction)
        count = count + 1;
      end
    end
  end
end

World(CalSmokeApp::Scroll)

Then(/^I see the scrolling views table$/) do
  query = "UITableView marked:'table'"
  wait_for_view(query)
end

When(/^I touch the (collection|table|scroll) views row$/) do |row_name|
  query = "UITableViewCell marked:'#{row_name} views row'"

  tap(query)
  wait_for_animations
end

Then(/^I see the (collection|table|scroll) views page$/) do |page_name|
  query = "view marked:'#{page_name} views page'"
  wait_for_view(query)
end

Then(/^I scroll the logos collection to the steam icon by mark$/) do
  query = "UICollectionView marked:'logo gallery'"

  options = {
    :scroll_position => :top,
  }

  scroll_to_item(query, 'steam', options)
end

Then(/^I scroll the logos collection to the github icon by index$/) do
  query = "UICollectionView marked:'logo gallery'"

  options = {
    :scroll_position => :center_vertical,
    :animated => false
  }

  scroll_to_item(query, 13, 0, options)
end

Then(/^I scroll up on the logos collection to the android icon$/) do
  query = "UICollectionView marked:'logo gallery'"
  icon_query = "UICollectionViewCell marked:'android'"

  visible = lambda {
    query(icon_query).count == 1
  }

  scroll_to(query, :up, visible)
  expect(query(icon_query).count).to be == 1
end

Then(/^I scroll the colors collection to the middle of the purple boxes$/) do
  query = "UICollectionView marked:'color gallery'"

  options = {
    :scroll_position => :top,
  }

  scroll_to_item(query, 12, 4, options)
end

Then(/^I scroll the logos table to the steam row by mark$/) do
  query = "UITableView marked:'logos'"

  options = {
    :scroll_position => :middle,
  }

  scroll_to_row_with_mark(query, 'steam', options)
end

Then(/^I scroll the logos table to the github row by index$/) do
  query = "UITableView marked:'logos'"

  options = {
    :scroll_position => :middle,
  }

  scroll_to_row(query, 13, options)
end

Then(/^I scroll up on the logos table to the android row$/) do
  query = "UITableView marked:'logos'"
  row_query = "UITableViewCell marked:'android'"

  visible = lambda {
    query(row_query).count == 1
  }

  scroll_to(query, :up, visible)
  expect(query(row_query).count).to be == 1
end

Then(/^I center the cayenne box to the middle$/) do
  query = "UIScrollView marked:'scroll'"
  wait_for_view(query)

  query(query, :centerContentToBounds)

  query = "view marked:'cayenne'"
  wait_for_view(query)
end

Then(/^I scroll up to the purple box$/) do
  query = "UIScrollView marked:'scroll'"
  wait_for_view(query)

  box_query = "view marked:'purple'"

  visible = lambda {
    result = query(box_query)
    if result.empty?
      false
    else
      rect = result.first['rect']
      center_y = rect['center_y']
      width = rect['width']
      center_y + (width/2) > 64
    end
  }

  scroll_to(query, :up, visible)
  expect(query(box_query).count).to be == 1
end

Then(/^I scroll left to the light blue box$/) do
  query = "UIScrollView marked:'scroll'"
  wait_for_view(query)

  box_query = "view marked:'light blue'"

  visible = lambda {
    query(box_query).count == 1
  }

  scroll_to(query, :left, visible)
  expect(query(box_query).count).to be == 1
end

Then(/^I scroll down to the gray box$/) do
  query = "UIScrollView marked:'scroll'"
  wait_for_view(query)

  box_query = "view marked:'gray'"

  visible = lambda {
    query(box_query).count == 1
  }

  scroll_to(query, :down, visible)
  expect(query(box_query).count).to be == 1
end

Then(/^I scroll right to the dark gray box$/) do
  query = "UIScrollView marked:'scroll'"
  wait_for_view(query)

  box_query = "view marked:'dark gray'"

  visible = lambda {
    query(box_query).count == 1
  }

  scroll_to(query, :right, visible)
  expect(query(box_query).count).to be == 1
end
