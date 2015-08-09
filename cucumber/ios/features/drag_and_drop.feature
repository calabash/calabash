@drag_and_drop
@gestures
Feature: Drag and Drop
In order to test the Calabash pan API
As a Calabash developer
I want to drag a view onto another view

Background: Navigate to the special tab
  Given I see the special tab

Scenario: Drag the red box to the left well
  When I drag the red box to the left well
  Then the well should change color
  And the box goes back to its original position

Scenario: Drag the blue box to the right well
  When I drag the blue box to the right well
  Then the well should change color
  And the box goes back to its original position

Scenario: Drag the green box to the left well
  When I drag the green box to the left well
  Then the well should change color
  And the box goes back to its original position

