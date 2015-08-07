@orientation
@rotation
Feature: Orientation and Rotation
In order to test how an app responds to rotation changes.
As a developer and tester
I want a Calabash Orientation API

Scenario: Find orientation of the status bar relative to the home button
  Given that the app has launched
  Then I check status bar orientation
  And I can tell if the app is in portrait or landscape

Scenario: Can rotate to landscape or portrait
  Given I see the gestures tab
  Then I can rotate to landscape
  And I can rotate to portrait

Scenario: View controller does not support rotation
  Given I see the controls tab
  And the view controller does not support rotation
  When I rotate left
  Then no rotation occurred

Scenario: View controller supports rotation
  Given I see the scrolls tab
  And the view controller does support rotation
  When I rotate right
  Then a rotation occurred

Scenario: Rotating to a specific home button position
  Given I see the gestures tab
  And the view controller does support rotation
  Then I rotate so the home button is on the right
  Then I rotate so the home button is on the left
  Then I rotate so the home button is on the top
  Then I rotate so the home button is on the bottom
