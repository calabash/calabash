@gesture
Feature: Tapping

  Calabash is capable of tapping any visible native view and webview element.
  It simulates a user gesture based on the coordinates returned by the query.

  Scenario: Tapping on a native view
    Given any visible view
    When Calabash is asked to tap it
    Then it will perform a tap gesture on the coordinates of the view
