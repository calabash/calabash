@full_reset
Feature: Selecting the default device
  Scenario Outline: Able to detect default device using ENV variables
    Given an ENV that uniquely identifies the default device for <os>
    When calabash/<os> is required
    Then Calabash sets a default device-target using the ENV

    When Calabash is asked to interact
    Then it selects a target with that device

    Examples:
      | os      |
      | android |
      | ios     |

  Scenario Outline: Unable to detect default device using ENV variables
    Given an ENV that does not uniquely identify the default device for <os>
    When calabash/<os> is required
    Then Calabash does not set a default device-target using the ENV
    But it does not fail

    When Calabash is asked to interact
    Then it fails stating why the default device target was not set

    Examples:
      | os      |
      | android |
      | ios     |

#  Scenario Outline: Unable to detect default device using ENV variables, but set explicitly
#    Given an ENV that does not uniquely identify the default device for <os>
#    When calabash/<os> is required
#    Then Calabash does not set a default device using the ENV
#    But it does not fail
#
#    Given the user explicitly sets the default device
#    When Calabash is asked to interact
#    Then it selects that device
#
#    Examples:
#      | os      |
#      | android |
#      | ios     |


