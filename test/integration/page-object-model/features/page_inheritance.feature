Feature: Page inheritance
  Calabash discourages inheriting from other implemented pages, therefore
  Calabash will not allow inheritance for Pages, except for the subclasses
  Android and IOS

  Scenario: Inheriting from an implemented page
    Given a user defined page that inherits from Page
    When the user creates a new page that inherits from the user defined page
    Then Calabash raises an error stating that page inheritance is discouraged


  Scenario Outline: Inheriting a platform-specific implementation from an implemented AbstractPage
    Given a user defined page that inherits from Page
    When the user creates a new page <platform> that inherits from the user defined page
    Then Calabash does not raise an error

    Examples:
      | platform  |
      | Android   |
      | IOS       |

  Scenario: Inheriting a non-platform-specific, i.e. Android or IOS, implementation from an implemented AbstractPage
    Given a user defined page that inherits from Page
    When the user creates a new page MySubPage that inherits from the user defined page
    Then Calabash raises an error stating that page inheritance is discouraged
