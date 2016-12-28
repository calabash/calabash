Feature: Page freezing
  Calabash discourages trying to save any application state in the test
  scripts, therefore Calabash freezes all Pages before their initializer has
  been run. This disables setting/changing instance variables in the page.

  Scenario: A page that sets a variable in its initializer
    Given a page that inherits from Page with an initializer that tries to set a variable
    When the user instantiates the page using new
    Then Calabash fails because the page is frozen

  Scenario: A page that sets a variable in a method
    Given a page that inherits from Page with a method that tries to set a variable
    When the user instantiates the page using new
    And the method of the page is called
    Then Calabash fails because the page is frozen

  Scenario: A page that sets a static variable
    Given a page that inherits from Page that sets a static variable when it is loaded
    When the user instantiates the page using new
    Then Calabash does not fail
