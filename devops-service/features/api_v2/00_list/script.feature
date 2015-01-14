@script
Feature: Scripts

  Scenario: Get scripts list
    When I send GET '/v2.0/scripts' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array
    And the array elements should be strings

  Scenario: Get scripts list without 'Accept' header
    When I send GET '/v2.0/scripts' query without headers 'Accept'
    Then response should be '406'

  Scenario: Get scripts list without privileges
    When I send GET '/v2.0/scripts' query with user without privileges
    Then response should be '401'
