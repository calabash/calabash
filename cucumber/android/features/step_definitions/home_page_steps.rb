
Given(/^I see the home page$/) do
  wait_for_view("* marked:'content'")
end

And(/^I navigate to the Sample Views page$/) do
  tap("* marked:'buttonGotoViewsSample'")
  queries =
        [
              "* marked:'checkBox'",
              "* marked:'listView'",
              "* marked:'ratingBar'"

        ]
  wait_for_views(queries)
end
