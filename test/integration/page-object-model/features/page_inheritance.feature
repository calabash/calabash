Feature: Page inheritance
  Calabash discourages inheriting from other implemented pages, therefore
  Calabash will not allow inheritance for Pages, and only once for
  AbstractPage, for the subclasses Android and IOS.

  Scenario Outline: Inheriting from an implemented page
    Given a user defined page that inherits from <page-type>
    When the user creates a new page that inherits from the user defined page
    Then Calabash raises an error stating that page inheritance is discouraged

    Examples:
      | page-type     |
      | Page          |
      | AbstractPage  |


  Scenario Outline: Inheriting a platform-specific implementation from an implemented AbstractPage
    Given a user defined page that inherits from AbstractPage
    When the user creates a new page <platform> that inherits from the user defined page
    Then Calabash does not raise an error

    Examples:
      | platform  |
      | Android   |
      | IOS       |

  Scenario: Inheriting a non-platform-specific, i.e. Android or IOS, implementation from an implemented AbstractPage
    Given a user defined page that inherits from AbstractPage
    When the user creates a new page MySubPage that inherits from the user defined page
    Then Calabash raises an error stating that page inheritance is discouraged
