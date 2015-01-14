@provider
Feature: Providers

  Scenario: Get list of providers
    When I send GET '/v2.0/providers' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array
    And the array elements should be strings

  Scenario: Get providers list without 'Accept' header
    When I send GET '/v2.0/providers' query without headers 'Accept'
    Then response should be '406'

  Scenario: Get providers list without privileges
    When I send GET '/v2.0/providers' query with user without privileges
    Then response should be '401'

