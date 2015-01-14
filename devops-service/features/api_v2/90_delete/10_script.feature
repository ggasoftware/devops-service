@script
Feature: Delete script

  Scenario: Delete script with user without privileges
    When I send DELETE '/v2.0/script/cucumber_test_script' query with user without privileges
    Then response should be '401'

  Scenario: Delete script without header 'Accept'
    When I send DELETE '/v2.0/script/cucumber_test_script' query without header 'Accept'
    Then response should be '406'

  Scenario: Delete script with id 'cucumber_test_script'
    When I send DELETE '/v2.0/script/cucumber_test_script' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an object
