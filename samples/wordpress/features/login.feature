@always_reset
Feature: Signing into the app
  As a user I want to be able to sign in. If I
  supply invalid credentials, I want to be notified.

  Scenario: Adding a self-hosted site
    Given I am on the login screen
    Then I should be able to add a self-hosted site

  Scenario: Entering invalid credentials
    Given I try to sign in using invalid credentials
    Then I should not be logged in
    And I should see an error message

  Scenario: Entering valid credentials
    Given I try to sign in using valid credentials
    Then I should be logged in

  Scenario: Signing out
    Given I am signed in
    Then I should be able to sign out