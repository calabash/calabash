@backdoor
Feature:  Backdoors
In order make UI testing faster and easier
As a tester
I want a way to get my app into a good shape for testing
and to get some state from my app at runtime

# We've been advocating only one kind of signature for backdoor methods.
#
# - (NSString *) backdoorWithString:(NSString *) argument
#
# The server can actually handle other kinds method signatures.
#
# The rules for valid backdoor methods are:
#
#  1. It must be implemented in the UIApplicationDelegate.
#  2. It must take exactly one argument.
#  3. The argument must be NSString, NSArray, NSDictionary, or NSNumber.
#  4. It must return an NSString, NSArray, NSDictionary, or NSNumber.
#
# Valid.
#
# - (NSNumber *) numberFromString:(NSString *) argument
# - (NSDictionary *) dictionaryFromString:(NSString *) argument
# - (NSArray *) arrayFromString:(NSString *) argument
#
# - (NSString *) stringWithDictionary:(NSDictionary *) argument
# - (NSString *) stringWithArray:(NSArray *) argument
# - (NSString *) stringWithNumber:(NSNumber *) argument
#
# Invalid: App will crash.
#
# - (void) backdoorWithVoidReturnType:(NSString *) argument
# - (BOOL) doesStateMatchStringArgument:(NSString *) argument
# - (NSUInteger) countOfCoreDataEntitiesWithName:(NSString *) argument
#
# Invalid: Will return unpredictable results or cause a crash.
#
# - (NSString *) stringWithBOOL:(BOOL) argument
# - (NSString *) stringWithNSUInteger:(NSUInteger) argument

Background: Navigate to the controls tab
  Given I see the controls tab

Scenario: Backdoor selector is unknown
  And I call backdoor with an unknown selector
  Then I should see a helpful error message

@expect_crash
Scenario: Calling backdoor with void return type causes a crash
  And I call backdoor on a method whose return type is void
  Then the app should crash

@expect_crash
Scenario: Calling backdoor with primitive return type causes a crash
  And I call backdoor on a method that returns a primitive
  Then the app should crash

@invalid_signature
Scenario: Backdoors with primitive argument (NSUInteger) are unpredictable
  And I call backdoor on a method that takes an NSUInteger argument
  Then I won't get back that integer as a string

@invalid_signature
Scenario: Backdoors with primitive argument (BOOL) are unpredictable
  And I call backdoor on a method that takes a boolean argument
  Then I won't get back that boolean as a string

@invalid_signature
Scenario: Backdoor with missing : in signature
  And I call a valid backdoor but forget to include the trailing colon
  Then backdoor will raise an argument error

Scenario: Backdoor that returns NSNumber
  And I call backdoor on a method that returns an NSNumber
  Then I get back the length of the argument I passed

Scenario: Backdoor that returns an NSDictionary
  And I call backdoor on a method with NSDictionary return type
  Then I get back the argument I passed as a dictionary

Scenario: Backdoor that returns an NSArray
  And I call backdoor on a method with NSArray return type
  Then I get back the argument I passed as an array

Scenario: Backdoor that takes an NSString argument
  And I call backdoor on a method that takes an NSString as an argument
  Then I should get back that string

Scenario: Backdoor that takes an NSDictionary argument
  And I call backdoor on a method that takes an NSDictionary as an argument
  Then I get back the length of that dictionary as a string

Scenario: Backdoor that takes an NSArray argument
  And I call backdoor on a method that takes an NSArray as an argument
  Then I get back the length of the array as a number

Scenario: Backdoor that take a NSNumber argument
  And I call backdoor on a method that takes a number argument
  Then I get back that number as a string

