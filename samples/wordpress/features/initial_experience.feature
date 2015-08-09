Feature: Initial experience
  As a user I want a helpful and simple initial
  experience with the app. I should be able to get help
  and login to an existing WordPress site.

  Scenario: Starting the application
    Given I have just started the application
    Then I should arrive at the login screen

  Scenario: Obtaining more information
    Given I am on the first screen
    And I choose to get more information
    Then I am taking to the information screen
    When I go back from the help screen
    Then I should be back on the login screen
