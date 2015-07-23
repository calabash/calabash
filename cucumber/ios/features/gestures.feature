@gestures
Feature:  Gestures
  In order to do things like touching, swiping, and dragging
  As a developer
  I want a Gesture API

  Scenario: Tap waits for views
    Given I see the first tab
    When I tap a view that does not exist
    Then a view-not-found wait error is raised

  Scenario:  Double tap
    Given I see the gestures tab
    When I double tap the box
    Then the gesture description changes to double tap

  Scenario:  Long press
    Given I see the gestures tab
    When I long press the box for 1 second
    Then the gesture description changes to long press
    When I long press the box for 2 seconds
    Then the gesture description changes to long press
