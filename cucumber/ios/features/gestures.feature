@gestures
Feature:  Gestures
  In order to do things like touching, swiping, and dragging
  As a developer
  I want a Gesture API

  @wip
  Scenario: Tap waits for views
    Given I see the first tab
    When I tap a view that does not exist
    Then a view-not-found wait error is raised
