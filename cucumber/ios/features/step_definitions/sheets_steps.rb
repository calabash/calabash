module CalSmoke
  module Sheets

    def sheet_query
      if ios8?
        "view:'_UIAlertControllerView'"
      else
        'UIActionSheet'
      end
    end

    def sheet_exists?(sheet_title=nil)
      if sheet_title.nil?
        !query(sheet_query).empty?
      else
        !query("#{sheet_query} descendant label marked:'#{sheet_title}'").empty?
      end
    end

    def wait_for_sheet
      timeout = 4
      message = "Waited #{timeout} seconds for a sheet to appear"

      wait_for(message, {:timeout => 4}) do
        sheet_exists?
      end
    end

    def wait_for_sheet_with_title(sheet_title)
      timeout = 4
      message = "Waited #{timeout} seconds for a sheet with title '#{sheet_title}' to appear"

      wait_for(message, {:timeout => 4}) do
        sheet_exists?(sheet_title)
      end
    end

    def tap_sheet_button(button_title)
      wait_for_sheet

      if ios8?
        query = "view:'_UIAlertControllerActionView' marked:'#{button_title}'"
      else
        query = "UIActionSheet child button child label marked:'#{button_title}'"
      end

      tap(query)
    end
  end
end

World(CalSmoke::Sheets)

When(/^I touch the show sheet button$/) do
  wait_for_view("view marked:'show sheet'")
  tap("view marked:'show sheet'")
end

Then(/^I see a sheet$/) do
  wait_for_sheet
end

Then(/^I see the "([^"]*)" sheet$/) do |sheet_title|
  wait_for_sheet_with_title(sheet_title)
end

Then(/^I can dismiss the sheet with the Cancel button$/) do
  tap_sheet_button('Cancel')
end

