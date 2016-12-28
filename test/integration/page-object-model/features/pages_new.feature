Feature: Instantiating pages
  Scenario Outline: Instantiating non-abstract pages
    Given a user defined page that inherits from Page
    And Calabash is targeting an <platform> platform
    When the user instantiates the page using new
    Then the user gets an instance of that particular page regardless of the platform

    Examples:
      | platform  |
      | Android   |
      | iOS       |
      | Unknown   |

  Scenario Outline: Instantiating abstract pages
    Given a user defined page that inherits from AbstractPage
    When the user creates a new page Android that inherits from the user defined page
    And the user creates a new page IOS that inherits from the user defined page
    And Calabash is targeting an <platform> platform
    When the user instantiates the page using new
    Then the user gets an instance of that page specialized for <platform>

    Examples:
      | platform  |
      | Android   |
      | iOS       |


  Scenario: Instantiating abstract pages with an unknown platform
    Given a user defined page that inherits from AbstractPage
    When the user creates a new page Android that inherits from the user defined page
    And the user creates a new page IOS that inherits from the user defined page
    And Calabash is targeting an Unknown platform
    When the user instantiates the page using new
    Then Calabash raises an error stating it cannot detect the current platform


