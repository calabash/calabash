@pan
Feature: Pan
  In order to perform swipes
  As a developer
  I want a Pan API

Scenario: Left-to-right screen pan in portrait
  Given I see the scrolls tab
  When I touch the table views row
  Then I see the table views page
  When I pan right on the screen (swipe to go back)
  Then I go back to the Scrolls page

Scenario: Left-to-right screen pan in landscape
  Given I see the scrolls tab
  And I rotate so the home button is on the right
  When I touch the collection views row
  Then I see the collection views page
  When I pan right on the screen (swipe to go back)
  Then I go back to the Scrolls page

Scenario: Panning on a scroll view
  Given I see the scrolls tab
  When I touch the scroll views row
  Then I see the scroll views page
  When I pan to the cayenne box on the simulator
  Then I expect an error to be raised about dragInsideWithOptions
  But I can pan to the cayenne box on the device

Scenario: Full-screen panning
  Given I see the gestures tab
  And I am on the panning gestures page
  Then I can pan full-screen bottom to top
  Then I can pan full-screen left to right
  Then I can pan full-screen top to bottom
  Then I can pan full-screen right to left
  And I clear the pan touch points
