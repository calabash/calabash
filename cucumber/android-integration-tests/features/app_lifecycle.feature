@default_device_set
Feature: App lifecycle
  Scenario: Installing and uninstalling an app
    Given I have not installed any apps on the device
    When I install "com.myapp"
    Then "com.myapp" should be installed
    When I uninstall "com.myapp"
    Then "com.myapp" should not be installed

  Scenario: Installing an app twice
    Given I have not installed any apps on the device
    When I install "com.myapp"
    Then "com.myapp" should be installed
    When I install "com.myapp" again
    Then "com.myapp" should be uninstalled and installed

#  Scenario: Ensuring an app is installed twice
#    Given I have not installed any apps on the device
#    When I ensure "com.myapp" is installed
#    Then "com.myapp" should be installed
#    When I ensure "com.myapp" is installed again
#    Then "com.myapp" should not have been uninstalled