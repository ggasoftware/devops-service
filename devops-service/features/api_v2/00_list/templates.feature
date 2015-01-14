@templates
Feature: Bootstrap templates

  Scenario: Get list of bootstrap templates
    When I send GET '/v2.0/templates' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array
    And the array elements should be strings

  Scenario: Get bootstrap templates list without 'Accept' header
    When I send GET '/v2.0/templates' query without headers 'Accept'
    Then response should be '406'

  Scenario: Get bootstrap templates list without privileges
    When I send GET '/v2.0/templates' query with user without privileges
    Then response should be '401'

