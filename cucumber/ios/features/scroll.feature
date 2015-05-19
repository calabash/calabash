@scroll
@no_ci
Feature: Testing scrolling

  Background: I am in the second tab
    Given I see the second tab

  Scenario: It should be able to find first & last cells moving up & down
    When I search for cell "cell 5" scrolling down
    Then I should see cell 5

    Given I see the cell 5
    When I search for cell "cell 1" scrolling up
    Then I should see cell 1

  Scenario: It should be able to find last cell after trying to scroll down 5 times
    When I scroll down for 5 times
    Then I should see cell 5

  Scenario: It should be able to find first cell after trying to scroll up 5 times
    When I scroll up for 5 times
    Then I should see cell 1

  Scenario: It should be able to find first cell after trying to scroll left 5 times
    When I scroll left for 5 times
    Then I should see cell 1

  Scenario: It should be able to find first cell after trying to scroll right 5 times
    When I scroll right for 5 times
    Then I should see cell 1
