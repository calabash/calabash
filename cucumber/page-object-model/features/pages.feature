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