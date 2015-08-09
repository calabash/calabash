@scroll
Feature: Testing scrolling
In order to scroll on tables, collections, map views, and web views
As a developer
I want a Scroll API

Background: Navigate to the scrolls tab
  Given I see the scrolls tab
  Then I see the scrolling views table

Scenario: Collection views
  When I touch the collection views row
  Then I see the collection views page
  Then I scroll the logos collection to the steam icon by mark
  Then I scroll the logos collection to the github icon by index
  Then I scroll up on the logos collection to the android icon
  Then I scroll the colors collection to the middle of the purple boxes

Scenario: Table views
  When I touch the table views row
  Then I see the table views page
  Then I scroll the logos table to the steam row by mark
  Then I scroll the logos table to the github row by index
  Then I scroll up on the logos table to the android row

Scenario: Scroll views
  When I touch the scroll views row
  Then I see the scroll views page
  Then I center the cayenne box to the middle
  Then I scroll up to the purple box
  Then I scroll left to the light blue box
  Then I center the cayenne box to the middle
  Then I scroll down to the gray box
  Then I scroll right to the dark gray box

