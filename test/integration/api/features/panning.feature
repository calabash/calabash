@gesture
Feature: Panning

  Calabash is capable of panning any visible native view and webview element.
  It simulates a user gesture based on the coordinates returned by the query.

  Calabash can either pan inside a view, or between two views.

  Scenario: Panning down inside a view
    Given any view that reacts to panning down
    When Calabash is asked to pan down on it
    Then it will perform a pan gesture on the coordinates of the view starting from the top going to the bottom

  Scenario: Panning up inside a view
    Given any view that reacts to panning up
    When Calabash is asked to pan up on it
    Then it will perform a pan gesture on the coordinates of the view starting from the bottom going to the top

  Scenario: Panning left inside a view
    Given any view that reacts to panning left
    When Calabash is asked to pan left on it
    Then it will perform a pan gesture on the coordinates of the view starting from the right going to the left

  Scenario: Panning right inside a view
    Given any view that reacts to panning right
    When Calabash is asked to pan right on it
    Then it will perform a pan gesture on the coordinates of the view starting from the left going to the right

  Scenario: Panning as fast as possible
    Given any view that reacts to panning left
    When Calabash is asked to pan left on it very fast
    Then Calabash will limit the inertia to ensure the pan is not a flick

  Scenario: Panning down inside the screen
    Given any screen that reacts to panning down
    When Calabash is asked to pan down on the screen
    Then it will perform a pan gesture on the coordinates of the screen starting from the top going to the bottom

  Scenario: Panning up inside the screen
    Given any screen that reacts to panning up
    When Calabash is asked to pan up on the screen
    Then it will perform a pan gesture on the coordinates of the screen starting from the bottom going to the top

  Scenario: Panning left inside the screen
    Given any screen that reacts to panning left
    When Calabash is asked to pan left on the screen
    Then it will perform a pan gesture on the coordinates of the screen starting from the right going to the left

  Scenario: Panning right inside the screen
    Given any screen that reacts to panning right
    When Calabash is asked to pan right on the screen
    Then it will perform a pan gesture on the coordinates of the screen starting from the left going to the right

  Scenario: Panning between to views
    Given a view that reacts to being panned
    When Calabash is asked to pan between it and another view
    Then it will perform a pan gesture between the views using their coordinates
  