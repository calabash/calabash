@screenshots
Feature:  Screenshots
In order to gain insights into my app
As a tester
I want a way to take a screenshot

Background:  The app has launched
  Given the app has launched
  And I have cleared existing screenshots for this feature
  And the scenario-screenshots subdirectory exists

Scenario: Default screenshot behavior
  When I take a screenshot with the default screenshot method
  Then the screenshot has a number appended to the name

Scenario: Can name a screenshot
  When I take a screenshot and specify the name
  Then the screenshot is saved with that name in the default location

Scenario: Save a screenshot to an absolute path
  When I take a screenshot and specify an absolute path
  Then the screenshot is created where I specified

Scenario: Save a screenshot to a relative path
  When I take a screenshot and specify a relative path
  Then the screenshot is created where I specified

