@gesture
Feature: Pinching
  Calabash is capable of performing a pinch gesture on a view or on the screen.

  A pinch gesture is a two-finger gesture, with each finger moving in the
  opposite direction of the other one.

  Scenario: Pinching out on a view
    Given a view that reacts to being pinched
    When Calabash is asked to pinch out on it
    Then it will perform a pinch gesture on the coordinates of the view heading outwards

  Scenario: Pinching in on a view
    Given a view that reacts to being pinched
    When Calabash is asked to pinch in on it
    Then it will perform a pinch gesture on the coordinates of the view heading inwards

  Scenario: Pinching out on the screen
    Given any screen that reacts to being pinched
    When Calabash is asked to pinch out on the screen
    Then it will perform a pinch gesture on the coordinates of the screen heading outwards

  Scenario: Pinching in on the screen
    Given any screen that reacts to being pinched
    When Calabash is asked to pinch in on the screen
    Then it will perform a pinch gesture on the coordinates of the screen heading inwards