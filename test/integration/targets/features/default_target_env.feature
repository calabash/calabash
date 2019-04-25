@full_reset
Feature: Selecting the default target
  Scenario Outline: Able to detect default target using ENV variables
    Given an ENV that uniquely identifies the default target for <os>
    When calabash/<os> is required
    Then Calabash sets a default target using the ENV

    When Calabash is asked to interact
    Then it selects that target

    Examples:
      | os      |
      | android |
      | ios     |

  Scenario Outline: Unable to detect default target using ENV variables
    Given an ENV that does not uniquely identify the default target for <os>
    When calabash/<os> is required
    Then Calabash does not set a default target using the ENV
    But it does not fail

    When Calabash is asked to interact
    Then it fails stating why the default device was not set

    Examples:
      | os      |
      | android |
      | ios     |