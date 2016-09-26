Feature: Working with pages
  Scenario Outline: Instantiating a page
    Given I am targeting an <os> device
    When I instantiate "MyPage"
    Then the page should be <os> "MyPage"

    Examples:
    | os      |
    | ios     |
    | Android |


  Scenario Outline: Asking for a specific OS page
    Given I am targeting an <os> device
    When I instantiate an Android page "MyPage"
    Then I should get an error, telling me no such <os> page exists

    Examples:
    | os      |
    | ios     |
    | Android |


  Scenario: Pages in submodules
    Given I am targeting an ios device
    When I instantiate "IPad::MyPage"
    Then the page should be ios "IPad::MyPage"

  Scenario Outline: Pages not including Calabash
    Given I am targeting an <os> device
    When I try to instantiate "MyNonIncludingPage"
    Then I should not get an error nor a warning

    Examples:
    | os      |
    | ios     |
    | Android |


  Scenario Outline: Pages including Calabash indirectly
    Given I am targeting an <os> device
    When I try to instantiate "MyIndirectlyIncludingPage"
    Then I should not get an error, but a warning

    Examples:
    | os      |
    | ios     |
    | Android |


  Scenario Outline: Pages including both Calabash Android and Calabash IOS
    Given I am targeting an <os> device
    When I try to instantiate "MyBothIncludingPage"
    Then I should get an error, telling me <os> "MyBothIncludingPage" includes both Calabash iOS and Calabash Android

    Examples:
      | os      |
      | ios     |
      | Android |


  Scenario: Pages that inherit from something that inherits from page
    Given I am targeting an Android device
    When I try to instantiate "MyIndirectlyInheritingPage"
    Then I should not get an error nor a warning

  Scenario: Pages that do not inherit from Calabash::Page
    Given I am targeting an Android device
    When I try to instantiate "NotAPage"
    Then I should get an error, telling me "Android::NotAPage" does not inherit from Calabash::Page