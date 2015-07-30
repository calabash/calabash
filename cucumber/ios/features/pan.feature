@pan
Feature: Pan
  In order to perform swipes
  As a developer
  I want a Pan API

Background: Navigate to the scrolls page
  Given I see the scrolls tab

Scenario: Left-to-right screen pan in portrait
  When I touch the table views row
  Then I see the table views page
  When I pan left on the screen
  Then I go back to the Scrolls page

Scenario: Left-to-right screen pan in landscape
  And I rotate so the home button is on the right
  When I touch the collection views row
  Then I see the collection views page
  When I pan left on the screen
  Then I go back to the Scrolls page

Scenario: Panning on a scroll view
  When I touch the scroll views row
  Then I see the scroll views page
  When I pan to the cayenne box on the simulator
  Then I expect an error to be raised about dragInsideWithOptions
  But I can pan to the cayenne box on the device

