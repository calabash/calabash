@gesture
Feature: Flicking

  Calabash is capable of flicking any visible native view and webview element.
  It simulates a user gesture based on the coordinates returned by the query.

  Calabash can flick inside a view.

  Scenario: Flicking down inside a view
    Given any view that reacts to flicking down
    When Calabash is asked to flick down on it
    Then it will perform a flick gesture on the coordinates of the view starting from the top going to the bottom

  Scenario: Flicking up inside a view
    Given any view that reacts to flicking up
    When Calabash is asked to flick up on it
    Then it will perform a flick gesture on the coordinates of the view starting from the bottom going to the top

  Scenario: Flicking left inside a view
    Given any view that reacts to flicking left
    When Calabash is asked to flick left on it
    Then it will perform a flick gesture on the coordinates of the view starting from the right going to the left

  Scenario: Flicking right inside a view
    Given any view that reacts to flicking right
    When Calabash is asked to flick right on it
    Then it will perform a flick gesture on the coordinates of the view starting from the left going to the right

  Scenario: Flicking has inertia
    Given any view that reacts to flicking left
    When Calabash is asked to flick left on it without being very slow
    Then Calabash will allow inertia in the gesture

  Scenario: Flicking down inside the screen
    Given any screen that reacts to flicking down
    When Calabash is asked to flick down on the screen
    Then it will perform a flick gesture on the coordinates of the screen starting from the top going to the bottom

  Scenario: Flicking up inside the screen
    Given any screen that reacts to flicking up
    When Calabash is asked to flick up on the screen
    Then it will perform a flick gesture on the coordinates of the screen starting from the bottom going to the top

  Scenario: Flicking left inside the screen
    Given any screen that reacts to flicking left
    When Calabash is asked to flick left on the screen
    Then it will perform a flick gesture on the coordinates of the screen starting from the right going to the left

  Scenario: Flicking right inside the screen
    Given any screen that reacts to flicking right
    When Calabash is asked to flick right on the screen
    Then it will perform a flick gesture on the coordinates of the screen starting from the left going to the right
