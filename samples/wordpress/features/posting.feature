Feature: Managing posts
  As a user I should be able to add, manage,
  and delete my posts.

  Scenario: Adding a new post
    Given I am signed in
    Then I should be able to add a new post
    And give it a title and some content
    When I publish the post
    Then I should see the new post in the list of posts

  @log_in
  Scenario: Reviewing a post
    Given I have added a post
    When I view that post
    Then I should show the title and content I gave it

  @log_in
  @android
  Scenario: Deleting a post
    Given I have added a post
    When I view that post
    Then I should be able to delete it
    And it should not appear in the list of posts

  @log_in
  @ios
  Scenario: Deleting a post
   Given I have added a post
   When I try to swipe-to-delete that post on a simulator
   Then I expect an error about a broken Apple API
   But I can delete that post on a device

  @log_in
  Scenario: Editing a post
    Given I have added a post
    When I view that post
    Then I should be able to edit it
    When I give it a new title
    Then it should appear with the changes in my list of posts
