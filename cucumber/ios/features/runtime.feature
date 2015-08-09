@runtime
Feature:  Runtime Attributes
In order to answer questions like: "Is this an iPhone 6+?"
As a developer
I want a Device Runtime API

Scenario: The Runtime API
  Given the app has launched
  Then I can ask if the device is a simulator or physical device
  And I can ask if the device is an iPad, iPhone, or iPod
  And I can ask if the device is in the iPhone family
  And I can ask if the app is an iPhone app emulated on an iPad
  And I can ask if the device is a 4in device
  And I can ask if the device is a 3.5in device
  And I can ask if the device is an iPhone 6 or iPhone 6+
  And I can ask for details about the device screen and app display details
  And I can ask what version of iOS the device is running
  And I can ask for the version of the Calabash iOS Server
  And I can ask specific questions about the iOS version
  And I can get version information about the app
  And I can get a full dump of the runtime attributes

