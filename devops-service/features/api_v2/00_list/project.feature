@project
Feature: Manage projects

  Scenario: Get list of all projects
    When I send GET '/v2.0/projects' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array
    And the array elements should be strings

  Scenario: Get list of all projects without 'Accept' header
    When I send GET '/v2.0/projects' query without headers 'Accept'
    Then response should be '406'

  Scenario: Get list of all projects without privileges
    When I send GET '/v2.0/projects' query with user without privileges
    Then response should be '401'

  Scenario: Get list of all projects - invalid path
    When I send GET '/v2.0/projects/foo' query
    Then response should be '404'
