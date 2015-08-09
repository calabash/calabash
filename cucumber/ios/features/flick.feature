@flick
Feature: Flick
In order to flick (swipes with velocity)
As a developer
I want a Flick API

Scenario: Left-to-right screen flick in portrait
  Given I see the scrolls tab
  When I touch the table views row
  Then I see the table views page
  When I flick right on the screen (swipe to go back)
  Then I go back to the Scrolls page

# Does not work on iPad; use pan.
Scenario: Left-to-right screen flick in landscape
  Given I see the scrolls tab
  And I rotate so the home button is on the right
  When I touch the collection views row
  Then I see the collection views page
  When I flick right on the screen (swipe to go back)
  Then I go back to the Scrolls page

