require 'chronic'

module CalSmokeApp
  module DatePicker

    def picker_current_date
      query = 'UIDatePicker'

      date_time_from_picker(query)
    end
  end
end

World(CalSmokeApp::DatePicker)

Given(/^I see the (time|date|date and time|countdown) (?:picker|timer)$/) do |id|
  case id
  when 'time'
    picker = 'show time picker'
  when 'date'
    picker = 'show date picker'
  when 'date and time'
    picker = 'show date and time picker'
  when 'countdown'
    picker = 'show countdown picker'
  end

  query = "view marked:'#{picker}'"
  tap(query)
  wait_for_animations
end

Then(/^the picker is in (time|date|date and time|countdown) mode$/) do |mode|

  query = 'UIDatePicker index:0'
  case mode
  when 'time'
    expect(time_mode?(query)).to be == true
  when 'date'
    expect(date_mode?(query)).to be == true
  when 'date and time'
    expect(date_and_time_mode?(query)).to be == true
  when 'countdown'
    expect(countdown_mode?(query)).to be == true
  end
end

And(/^the picker maximum and minimum dates are not set$/) do
  query = 'UIDatePicker index:0'

  query(query, [{setMaximumDate:nil}])
  query(query, [{setMinimumDate:nil}])
end

And(/^the picker date is set to now$/) do
  query = "view:'CalDatePickerView'"

  result = query(query, :setDateToNow).first
  expect(result).to be == 1
end

And(/^the picker (minimum|maximum) date is now$/) do |min_max|
  query = "view:'CalDatePickerView' marked:'date picker'"

  if min_max == 'minimum'
    result = query(query, :setMinimumDateToNow).first
  else
    result = query(query, :setMaximumDateToNow).first
  end
  expect(result).to be == 1
end

Then(/^I change the date picker time to "([^"]*)"$/) do |time_str|
  target_time = Time.parse(time_str)

  current_date = picker_current_date

  current_date = DateTime.new(current_date.year,
                              current_date.mon,
                              current_date.day,
                              target_time.hour,
                              target_time.min,
                              0,
                              target_time.gmt_offset)

  picker_set_date_time(current_date)
  wait_for_animations

  new_time = Chronic.parse(picker_current_date.to_s)

  label_date_string = query("UILabel marked:'time'", :text).first
  label_time = Chronic.parse("today at #{label_date_string}")

  expect(new_time.to_s).to be == label_time.to_s
end

Then(/^I change the date picker date to "([^"]*)"$/) do |date_str|
  target_date = Date.parse(date_str)

  current_time = picker_current_date

  date_time = DateTime.new(target_date.year,
                           target_date.mon,
                           target_date.day,
                           current_time.hour,
                           current_time.min,
                           0,
                           Time.now.sec,
                           current_time.offset)

  picker_set_date_time(date_time)
  wait_for_animations

  new_date_str = picker_current_date.strftime("%a %b %e %Y")
  label_date_string = query("UILabel marked:'time'", :text).first

  actual = Chronic.parse(new_date_str).to_s
  expected = Chronic.parse(label_date_string).to_s
  expect(actual).to be == expected
end

Then(/^I change the date picker date to "([^"]*)" at "([^"]*)"$/) do |date_str, time_str|
  target_time = Time.parse(time_str)
  target_date = Date.parse(date_str)

  current_date = picker_current_date

  date_time = DateTime.new(target_date.year,
                           target_date.mon,
                           target_date.day,
                           target_time.hour,
                           target_time.min,
                           0,
                           Time.now.sec,
                           current_date.offset)

  picker_set_date_time(date_time)
  wait_for_animations

  new_date_str = picker_current_date.strftime("%a %b %e %Y %I:%M")
  label_date_string = query("UILabel marked:'time'", :text).first

  actual = Chronic.parse(new_date_str).to_s
  expected = Chronic.parse(label_date_string).to_s
  expect(actual).to be == expected
end

Given(/^the picker interval is (\d+) minutes?$/) do |interval|
  query = 'UIDatePicker index:0'
  query(query, [{setMinuteInterval:interval.to_i}])
end

Then(/^I change the time on the picker to (\d+) minutes? (from|before) now$/) do |minutes, past_future|
  if past_future == 'from'
    time = Chronic.parse("#{minutes} minutes from now").to_s
  else
    time = Chronic.parse("#{minutes} minutes before now").to_s
  end

  target_date = DateTime.parse(time)

  picker_set_date_time(target_date)

  new_time = Chronic.parse(picker_current_date.to_s)

  label_date_string = query("UILabel marked:'time'", :text).first
  label_time = Chronic.parse("today at #{label_date_string}")

  expect(new_time.to_s).to be == label_time.to_s
end


Then(/^trying to set the date to before now raises an error$/) do
  time = Chronic.parse('yesterday')
  target_date = DateTime.parse(time.to_s)

  expect do
    picker_set_date_time(target_date)
  end.to raise_error RuntimeError,
                     /Target date comes before the minimum date./
end

Then(/^trying to set the date to after now raises an error$/) do
  time = Chronic.parse('tomorrow')
  target_date = DateTime.parse(time.to_s)

  expect do
    picker_set_date_time(target_date)
  end.to raise_error RuntimeError,
                     /Target date comes after the maximum date./
end

Then(/^asking for the maximum date raises an error$/) do
  query = 'UIDatePicker index:0'

  expect do
    maximum_date_time_from_picker(query)
  end.to raise_error RuntimeError,
                     /Countdown pickers do not have a maximum date./
end

Then(/^asking for the minimum date raises an error$/) do
  query = 'UIDatePicker index:0'

  expect do
    minimum_date_time_from_picker(query)
  end.to raise_error RuntimeError,
                     /Countdown pickers do not have a minimum date./
end

And(/^trying to set the date raises an error$/) do
  target_date = DateTime.now

  expect do
    picker_set_date_time(target_date)
  end.to raise_error RuntimeError,
                     /Setting the date or time on a countdown picker is not supported/
end

Then(/^trying to set date with a (Time|Date) object raises an error$/) do |date_or_time|
  if date_or_time == 'Time'
    target_date = Time.now
  else
    target_date = Date.today
  end

  expect do
    picker_set_date_time(target_date)
  end.to raise_error ArgumentError,
                     /must be a DateTime but found/
end

