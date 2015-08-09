@date_picker
Feature: Date Picker
In order quickly manipulate UIDatePickers
As a developer
I want a Date Picker API

# The Calabash iOS Date Picker API programmically sets
# the time, date, or date and time of UIDatePickers and
# uses Objective-C methods to generate UIEvents so your
# app will react to the date changes.
#
# The sample app has a UILabel whose contents are updated
# when the date on the UIDatePicker changes.
#
# The Date Picker API requires the target date be a ruby
# DateTime object.  We recommend the 'chronic' gem to parse
# natural language to Time objects which can then be converted
# to DateTime objects.
#
# > time = Chronic.parse("next Tuesday at 13:00")
# > date_time = DateTime.parse(time.to_s)
# > picker_set_time(date_time)
#
# The API has been tested in various time zones and tested
# once while crossing the international date line (on a boat).
# With that said, the API makes some assumptions about locales
# and time zones.  It is possible to customize the ruby date
# format and Objective-C date format to get the behavior you
# need.  You will need to monkey patch the following methods:
#
#  * date_picker_ruby_date_format
#  * date_picker_objc_date_format
#
# Before going down this path, we recommend that you ask for
# advice on the Calabash support channels.

Background: Navigate to the date picker tab
  Given I see the date picker tab

Scenario: API only accepts DateTime
  Given I see the date picker
  Then trying to set date with a Time object raises an error
  Then trying to set date with a Date object raises an error

Scenario: Cannot set date before minimum date
  Given I see the date picker
  And the picker minimum date is now
  Then the picker is in date mode
  Then trying to set the date to before now raises an error

Scenario: Cannot set date after maximum date
  Given I see the date picker
  And the picker maximum date is now
  Then the picker is in date mode
  Then trying to set the date to after now raises an error

Scenario: Operations on countdown timer are restricted
  Given I see the countdown timer
  Then the picker is in countdown mode
  Then asking for the maximum date raises an error
  Then asking for the minimum date raises an error
  And trying to set the date raises an error

Scenario: Setting the time
  Given I see the time picker
  And the picker maximum and minimum dates are not set
  Then the picker is in time mode
  Then I change the date picker time to "10:45"
  Then I change the date picker time to "12:45 AM"
  Then I change the date picker time to "19:35"
  Then I change the date picker time to "1:35"
  Then I change the date picker time to "6:45 PM"
  Then I change the date picker time to "6:45 AM"

Scenario: Setting the date
  Given I see the date picker
  And the picker maximum and minimum dates are not set
  Then the picker is in date mode
  Then I change the date picker date to "July 28 2009"
  Then I change the date picker date to "Dec 31 3029"
  Then I change the date picker date to "1980-09-14"
  Then I change the date picker date to "Dec 31 29"
  Then I change the date picker date to "1492.11.11"

Scenario: Setting the date and time
  Given I see the date and time picker
  And the picker maximum and minimum dates are not set
  Then the picker is in date and time mode
  Then I change the date picker date to "July 28" at "15:23"
  Then I change the date picker date to "28 Aug" at "12:23 AM"
  Then I change the date picker date to "2013-03-14" at "12:23"

Scenario: Advancing the time by minutes
  Given I see the time picker
  And the picker maximum and minimum dates are not set
  And the picker date is set to now
  And the picker interval is 5 minutes
  Then I change the time on the picker to 20 minutes from now
  Given the picker interval is 1 minute
  Then I change the time on the picker to 13 minutes before now

