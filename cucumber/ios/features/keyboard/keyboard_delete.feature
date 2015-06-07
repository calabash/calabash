@keyboard
@numeric_keyboard
@delete_key
Feature: keyboard delete
  In order to test keyboard interactions
  As a developer and tester
  I want to be able to app the delete key

  Background: I should see the first view
    Given I see the first tab

  Scenario: exercise the default keyboard
    And the default keyboard is showing
    And the text field has "mary had a little limb" in it
    And realize my mistake and delete 3 characters and replace with "amb"
