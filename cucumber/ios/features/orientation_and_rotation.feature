@wip
@orientation
@rotation
Feature: Orientation and Rotation
  In order to test how an app responds to rotation changes.
  As a developer and tester
  I want a Calabash orientation API

  Scenario: Find orientation of the status bar relative to the home button
    Given that the app has launched
    Then I check status bar orientation
    And I can tell if the app is in portrait or landscape
