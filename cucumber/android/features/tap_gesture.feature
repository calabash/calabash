Feature:  Tap Gesture
  In order to test the Tap Gesture API
  As a Calabash developer and tester
  I want Scenarios that demonstrate tapping

  Scenario:  Single tap
    Given I see the home page
    And I navigate to the Sample Views page
    When I touch the check box
    Then the check box should change state.
