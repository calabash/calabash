
When(/^I touch the check box$/) do
  result = wait_for_view("* marked:'checkBox'")
  @checkbox_checked = result['checked']
  tap("* marked:'checkBox'")
end

Then(/^the check box should change state\.$/) do
  result = wait_for_view("* marked:'checkBox'")
  unless result['checked'] != @checkbox_checked
    fail "Expected checkbox to be #{!@checkbox_checked ? 'checked' : 'unchecked'} found 'checked' => #{result['checked']}"
  end
end
