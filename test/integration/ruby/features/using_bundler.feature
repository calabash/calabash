Feature: Using bundler
  Calabash strongly recommends that it is ran using bundler,
  therefore we need to be able to function and detect all versions
  of bundler.

  @cleanup_tmp_dir
  Scenario Outline: Running Calabash using bundler
    Given I am using bundler <version> and have a Gemfile targeting Calabash
    When I run Calabash with bundle exec
    Then Calabash should work and detect that we are running using Bundler

    Examples:
      | version |
      | latest  |
      | 1.13.1  |
      | 1.12.5  |
