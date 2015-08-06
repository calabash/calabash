@gestures
@tapping
Feature: Gestures
In order to test tapping
As a developer
I want a Tap API

Background: Navigate to Tapping page
  Given I see the gestures tab
  And I see the tapping page

Scenario:  Double tap
  When I double tap the left box
  Then the gesture description changes to double tap

Scenario:  Long press
  When I long press the left box for 1 second
  Then the gesture description changes to long press
  When I long press the right box for 2 seconds
  Then the gesture description changes to long press

