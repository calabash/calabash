@keyboard
@numeric_keyboard
@delete_key
Feature: keyboard delete
  In order to test keyboard interactions
  As a developer and tester
  I want to be able to app the delete key

  Background: I should see the first view
    Given I see the first tab

  Scenario: Default keyboard
    And the default keyboard is showing
    And the text field has "mary had a little limb" in it
    And realize my mistake and delete 3 characters and replace with "amb"

  @ascii
  Scenario: Ascii keyboard
    And the ascii keyboard is showing
    Then I text my friend a facepalm "(>_>]"
    And realize my mistake and delete 1 character and replace with ")"

  Scenario: Numbers and punctuation keyboard
    And the numbers and punctuation keyboard is showing
    Then I say, "Yeah"
    Then he said, "Hear what I say, sir."
    And he said, "You do what I say, sir."
    And he said, "Put your hand on your head, sir."
    And he said, "And you will get no hurt now."
    Then I say, "Yeah"
    Then he said, "What's your number?"
    Then I say, "54-36", that's my number
    And realize my mistake and delete 2 characters and replace with "46"

  @url
  Scenario: URL keyboard
    And the url keyboard is showing
    Then I try to visit "amazon.com.uk"
    And realize my mistake and delete 4 characters and replace with ".uk"
