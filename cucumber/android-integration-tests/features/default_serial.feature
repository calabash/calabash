Feature: Default Serial
  Scenario: No visible devices
    Given no devices are visible
    When I ask for the default serial
    Then Calabash should fail, telling me no devices are available

  Scenario: More than one visible device
    Given two devices, "device-a" and "device-b", are visible
    When I ask for the default serial
    Then Calabash should fail, telling me more than one device is available

  Scenario: Only one device connected
    Given one device, "my-device", is visible
    When I ask for the default serial
    Then Calabash should not fail and "my-device" should be given as the default serial

  Scenario: More than one visible device and I have set a default serial
    Given two devices, "device-a" and "device-b", are visible
    And I have set the default identifier to "device-b"
    When I ask for the default serial
    Then Calabash should not fail and "device-b" should be given as the default serial

  Scenario Outline: The selected identifier is not visible
    Given <devices>
    And I have set the default identifier to "device-c"
    When I ask for the default serial
    Then Calabash should fail, telling me the given identifier, "device-c", is not visible

    Examples:
      | devices                                             |
      | two devices, "device-a" and "device-b", are visible |
      | no devices are visible |
