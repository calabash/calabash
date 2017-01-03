Feature: Generating a Cucumber skeleton
  @cleanup_tmp_dir
  Scenario: Generating a Cucumber skeleton in en empty directory
    Given I am in an empty working directory
    When I use the Calabash CLI command "generate-cucumber"
    Then I have a basic Cucumber skeleton

  @cleanup_tmp_dir
  Scenario Outline: Running a Cucumber skeleton with applications
    Given I have generated a Cucumber skeleton
    When I run Cucumber with CAL_APP set to <app>
    Then the auto generated skeleton runs with the <os> platform
    Examples:
      | app        | os        |
      | app.apk    | Android   |
      | app.ipa    | iOS   |

  @cleanup_tmp_dir
  Scenario: Running dry-run
    Given I have generated a Cucumber skeleton
    And I have added a page
    When I run Cucumber as dry-run
    Then it does not fail as the skeleton defines a page stub
