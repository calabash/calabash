@wip
@keyboard
Feature: Keyboard
  In order to test how to interact with keyboard
  As a developer and tester
  I want a Calabash Keyboard API

  Background: I should see the first view
    Given I see the first tab

  Scenario: I should be able to type something
    And I touch the text field
    Then I wait for the keyboard
    Then I type "Hello"
    And the text in the text field should be "Hello"

  Scenario: I can ask questions about the keyboard visibility
    And I touch the text field
    Then I wait for the keyboard
    And the keyboard is visible
    And the docked keyboard is visible
    And the undocked keyboard is not visible
    And the split keyboard is not visible
