@gesture
Feature: Long pressing

  Calabash is capable of long pressing any visible native view and webview element.
  It simulates a user gesture based on the coordinates returned by the query

  Scenario: Long pressing with default duration
    Given any visible view that reacts to long pressing
    When Calabash is asked to long press it
    Then it will perform a long press gesture on the coordinates of the view

  Scenario: Long pressing with a set duration
    Given any visible view that reacts to long pressing
    When Calabash is asked to long press it for 2 seconds
    Then it will perform a long press gesture on the coordinates of the view for 2 seconds