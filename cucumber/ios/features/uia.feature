@uia
Feature: UIA Automation Javascript API
In order to test complicated behaviors
As a developer and tester
I want to interact with the UIAutomation Javascript API

Scenario: Tapping
Given I see the controls tab
  Then I use UIA to touch the text field
  And I wait for the keyboard
  Then I use UIA to type "Hello"
  And the text in the text field should be "Hello"
  Then I use UIA to touch the Done button on the keyboard

