@script
Feature: Add new script

  Scenario: Add new script with user without privileges
    When I send PUT '/v2.0/script/cucumber_test_script' query with user without privileges
    Then response should be '401'

  Scenario: Add new script without header 'Accept'
    When I send PUT '/v2.0/script/cucumber_test_script' query with body without header 'Accept'
    """
    echo "cucumber test script"
    """
    Then response should be '406'

  Scenario: Add new script with id 'cucumber_test_script'
    When I send PUT '/v2.0/script/cucumber_test_script' query with body
    """
    echo "cucumber test script"
    """
    Then response should be '201'
