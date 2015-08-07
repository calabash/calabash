@selectors
Feature: Calling Arbitrary Selectors
In order to speed up testing and gain insights about my app
As a developer and tester
Want a way of calling arbitrary selectors on UIViews

# Calabash can call arbitrary selectors on UIView and UIView subclasses.
#
# The classic example is setting the text of a UITextField.
#
# query("UITextField marked:'username'", [{setText:'launisch'}])
#
# In this case, 'setText' is the Objective-C selector.
#
# Consider this use case.  You are testing a UIView with an image view
# and a label. During a test you want to change the image and the caption.
#
# @interface MyView : UIView
#
# @property(...) UIImageView *imageView;
# @property(...) UILabel *caption;
#
# @end
#
# @implementation MyView
#
# - (void) setImageWithURL:(NSString *) url caption:(NSString *) caption {
#   UIImage *image = // Fetch the image from URL
#   self.imageView.image = image;
#   self.label.text = caption;
# }
#
# @end
#
# In the view's Controller or in the Interface Builder, you set the the
# accessibilityIdentifier to 'my view'.
#
# You can call this method from Calabash like this:
#
# query("view marked:'my view', [{setImageWithURL:'https://some/url.png',
#                                         caption:'Funny Cat!'}])
#
# Another way to add a selector to a view is to use an Objective-C category.
#
# In your View Controller .m file
#
# // Google Map View
# @interface GMSMapView (CalabashAdditions)
#
# - (NSString *) JSONRepresentationOfPins;
#
# @end
#
# @implementation GMSMapView (CalabashAdditions)
#
# - (NSString *) JSONRepresentationOfPins {
#  // Google Map Views are OpenGL based so they are opaque to Calabash queries.
#  // However, you can manage the pins on the map manually and return the list
#  // of visible pins as a JSON string.
# }
#
# @end
#
# query('GSMapView', :JSONRepresentationOfPins)

Background: Navigate to the controls page
  Given I see the controls tab

Scenario: Unknown selector
  When I call an unknown selector on a view
  Then I expect to receive back "*****"

Scenario: Use __self__ to reference self
  When I call a method that references the matched view
  Then I expect to receive back "Self reference! Hurray!"

  # Demonstrates how to chain methods
  # view.alarm.isOn
  # [view.alarm setIsOn:1]
  Scenario: Selector chaining
  Then the view alarm property is off
  And I can turn the alarm on

Scenario: Selector arguments
  Then I call selector with pointer argument
  Then I call selector with int argument
  Then I call selector with unsigned int argument
  Then I call selector with short argument
  Then I call selector with unsigned short argument
  Then I call selector with float argument
  Then I call selector with double argument
  Then I call selector with long double argument
  Then I call selector with c string argument
  Then I call selector with char argument
  Then I call selector with unsigned char argument
  Then I call selector with BOOL argument
  Then I call selector with long argument
  Then I call selector with unsigned long argument
  Then I call selector with long long argument
  Then I call selector with unsigned long long argument
  Then I call selector with point argument
  Then I call selector with rect argument

Scenario: Selector return values
  Then I call a selector that returns void
  Then I call a selector that returns a pointer
  Then I call a selector that returns a char
  Then I call a selector that returns an unsigned char
  Then I call a selector that returns a c string
  Then I call a selector that returns a BOOL
  Then I call a selector that returns a bool
  Then I call a selector that returns an int
  Then I call a selector that returns an unsigned int
  Then I call a selector that returns a short
  Then I call a selector that returns an unsigned short
  Then I call a selector that returns a double
  Then I call a selector that returns a long double
  Then I call a selector that returns a float
  Then I call a selector that returns a long
  Then I call a selector that returns an unsigned long
  Then I call a selector that returns a long long
  Then I call a selector that returns an unsigned long long
  Then I call a selector that returns a point
  Then I call a selector that returns a rect
  Then I call a selector that returns a CalSmokeAlarm struct

@failing
Scenario: Selector with multiple arguments
  Then I call a selector on a view that has 3 arguments

@failing
Scenario:  Chained selector with multiple arguments
  Then I make a chained call to a selector with 3 arguments

