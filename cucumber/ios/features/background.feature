@background
Feature: Send App to Background
In order to test how my app behaves when it goes to the background
As a developer
I want a Background API

Background: Launch the app
  Given the app has launched

Scenario: Simulate touching the home button
  Then backgrounding the app for less than one second raises an error
  And backgrounding the app for more than sixty seconds raises an error
  But I can send the app to the background for 1 second

@shared_element
Scenario: Backgrounding works with :shared_element
  Then I can background the app when UIA strategy is :shared_element

@host
Scenario: Backgrounding works with :host
  Then I can background the app when UIA strategy is :host

@preferences
@simulator_only
Scenario: Background works with :preferences
  Then I can background the app when UIA strategy is :preferences

