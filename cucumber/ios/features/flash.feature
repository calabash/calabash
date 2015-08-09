@flash
Feature: Flash
In order to explore my app's view heirarchy
As an app tester and develop
I want Calabash to be able to visually indicate which views match a query

Background: Navigate to special tab
 Given I see the special tab

Scenario: Flashing
  Then I can flash the buttons
  And I can flash the labels in the tab bar
  When the flash query matches no views
  Then flash returns an empty array

