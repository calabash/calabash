@simulator_only
@ensure_ipad_1x
Feature: iPhone app emulated on iPad
In order to test iPhone apps emulated on iPads
As a developer
I want a way to ensure the app is displayed @ 1x zoom

# Calabash cannot interact with these apps in 2x mode because the touch
# coordinates cannot be reliably translated from normal iPhone dimensions
# to the emulated dimensions.
#
# After launch, Calabash will detect that the app is being emulated on
# an iPad and will tap the 1X/2X zoom button to get the app into the correct
# scale.

@wip
Scenario: Ensure app in 1x
  Given the iPhoneOnly app has launched
  Then the app will be in 1x mode
  Then I can tap the Moss box with UIA

  Then we fail because gestures on emulated apps are broken

  Then I can touch all the boxes

  Then I rotate so the home button is on the right
  Then I can touch all the boxes

  Then I rotate so the home button is on the top
  Then I can touch all the boxes

  Then I rotate so the home button is on the left
  Then I can touch all the boxes

