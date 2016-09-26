@full_reset
Feature: Requiring Calabash
  Scenario: Requiring Calabash Android
    When I require "calabash/android"
    Then I have access to the Calabash API and Calabash Android API

  Scenario: Requiring Calabash iOS
    When I require "calabash/ios"
    Then I have access to the Calabash API and Calabash iOS API

  @store_require_errors
  Scenario: Requiring both Calabash Android and Calabash iOS
    Given I have required "calabash/android"
    When I require "calabash/ios"
    Then I get an error as I cannot include both Calabash iOS and Calabash Android

  @store_require_errors
  Scenario: Requiring both Calabash iOS and Calabash Android
    Given I have required "calabash/ios"
    When I require "calabash/android"
    Then I get an error as I cannot include both Calabash iOS and Calabash Android

  Scenario Outline: Requiring Calabash <os> allows me to use the Calabash API
    Given I have required "calabash/<os>"
    When I invoke a method from the Calabash API
    Then the <os> specific implementation is called

    Examples:
      | os      |
      | android |
      | ios     |