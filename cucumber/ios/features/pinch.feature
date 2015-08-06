@pinch
Feature: Pinch
In order to zoom in and out
As a developer
I want a Pinch API

Scenario: Pinch in and out on a view
  Given I see the gestures tab
  And I see the pinching page
  When I pinch out on the box, it gets bigger
  When I pinch in on the box, it gets smaller
  And I can zoom in on the box
  And I can zoom out on the box

Scenario: Zoom in and out on a map
  Given I see the scrolls tab
  And I see the map views page
  Then I can zoom out on the map
  And I can zoom in on the map

Scenario: Zoom in and out on a map
  Given I see the scrolls tab
  And I see the map views page
  Then I can zoom out on the screen
  And I can zoom in on the screen

Scenario: Pinch in and out on the screen
  Given I see the scrolls tab
  And I see the map views page
  Then I can pinch in on the screen
  And I can pinch out on the screen

