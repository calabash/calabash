module CalSmoke
  module Alerts

    def alert_exists?(alert_title=nil)
      if alert_title.nil?
        res = uia('uia.alert() != null')
      else
        if ios6?
          res = uia("uia.alert().staticTexts()['#{alert_title}'].label()")
        else
          res = uia("uia.alert().name() == '#{alert_title}'")
        end
      end

      if res.empty?
        false
      else
        res.first
      end
    end

    def alert_button_exists?(button_title)
      unless alert_exists?
        fail('Expected an alert to be showing')
      end

      res = uia("uia.alert().buttons()['#{button_title}']")

      if res.empty?
        false
      else
        res.first
      end
    end

    def wait_for_alert
      timeout = 4
      message = "Waited #{timeout} seconds for an alert to appear"
      wait_for(message, {:timeout => timeout}) do
        alert_exists?
      end
    end

    def wait_for_alert_with_title(alert_title)
      timeout = 4
      message = "Waited #{timeout} seconds for an alert with title '#{alert_title}' to appear"

      wait_for(message, {:timeout => timeout}) do
        alert_exists?(alert_title)
      end
    end

    def tap_alert_button(button_title)
      wait_for_alert

      uia("uia.alert().buttons()['#{button_title}'].tap()")
    end

    def alert_view_query_str
      if ios8? || ios9?
        "view:'_UIAlertControllerView'"
      elsif ios7?
        "view:'_UIModalItemAlertContentView'"
      else
        'UIAlertView'
      end
    end

    def button_views
      wait_for_alert

      if ios8? || ios9?
        query = "view:'_UIAlertControllerActionView'"
      elsif ios7?
        query = "view:'_UIModalItemAlertContentView' descendant UITableView descendant label"
      else
        query = 'UIAlertView descendant button'
      end
      query(query)
    end

    def button_titles
      button_views.map { |res| res['label'] }.compact
    end

    def leftmost_button_title
      with_min_x = button_views.min_by do |res|
        res['rect']['x']
      end
      with_min_x['label']
    end

    def rightmost_button_title
      with_max_x = button_views.max_by do |res|
        res['rect']['x']
      end
      with_max_x['label']
    end

    def all_labels
      wait_for_alert
      query = "#{alert_view_query_str} descendant label"
      query(query)
    end

    def non_button_views
      button_titles = button_titles()
      all_labels = all_labels()
      all_labels.select do |res|
        !button_titles.include?(res['label']) &&
              res['label'] != nil
      end
    end

    def alert_message
      with_max_y = non_button_views.max_by do |res|
        res['rect']['y']
      end

      with_max_y['label']
    end

    def alert_title
      with_min_y = non_button_views.min_by do |res|
        res['rect']['y']
      end
      with_min_y['label']
    end
  end
end

World(CalSmoke::Alerts)

When(/^I touch the show alert button$/) do
  query = "view marked:'show alert'"
  tap(query)
end

Then(/^I see an alert$/) do
  wait_for_alert
end

Then(/^I see the "([^"]*)" alert$/) do |alert_title|
  wait_for_alert_with_title(alert_title)
end

And(/^I can dismiss the alert with the OK button$/) do
  tap_alert_button('OK')
end

And(/^the title of the alert is "([^"]*)"$/) do |title|
  expect(alert_title).to be == title
end

And(/^the message of the alert is "([^"]*)"$/) do |message|
  expect(alert_message).to be == message
end

And(/^the (left|right) hand button is "([^"]*)"$/) do |position, title|
  if position == 'left'
    actual_title = leftmost_button_title
  else
    actual_title = rightmost_button_title
  end
  expect(actual_title).to be == title
end

