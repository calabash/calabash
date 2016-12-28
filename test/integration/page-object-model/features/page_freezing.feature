Feature: Page freezing
  Calabash discourages trying to save any application state in the test
  scripts, therefore Calabash freezes all AbstractPages and Pages before
  their initializer has been run. This disables setting/changing instance
  variables in the page.

  Scenario Outline: A page that sets a variable in its initializer
    Given a page that inherits from <page-type> with an initializer that tries to set a variable
    When the user instantiates the page using new
    Then Calabash fails because the page is frozen

    Examples:
      | page-type    |
      | Page         |
      | AbstractPage |

  Scenario Outline: A page that sets a variable in a method
    Given a page that inherits from <page-type> with a method that tries to set a variable
    When the user instantiates the page using new
    And the method of the page is called
    Then Calabash fails because the page is frozen

    Examples:
    | page-type     |
    | Page          |
    | AbstractPage  |

  Scenario Outline: A page that sets a static variable
    Given a page that inherits from <page-type> that sets a static variable when it is loaded
    When the user instantiates the page using new
    Then Calabash does not fail

    Examples:
    | page-type     |
    | Page          |
    | AbstractPage  |