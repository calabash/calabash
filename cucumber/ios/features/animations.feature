@animations
Feature:  Animations
  In order to demonstrate that Calabash works when there are animations
  As a Calabash maintainer
  I want some Scenarios with views that animate

  Background: Get me to the third tab
    Given I see the third tab

  @backdoor
  Scenario: Start an animation and wait for it to finish
    And I have started an animation that lasts 4 seconds
    Then I can wait for the animation to stop

  @network_indicator
  @backdoor
  Scenario: Start the network indicator and wait for it to finish
    And I start the network indicator for 4 seconds
    Then I can wait for the indicator to stop

  Scenario: Call wait_for_animation with a nil query
    When I pass an empty query to wait_for_animations_in
    Then the app should not crash
    And an error should be raised
