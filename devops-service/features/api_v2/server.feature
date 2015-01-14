@server
Feature: Create server for existing environment
  Scenario: Get project 'test'
    When I send GET '/v2.0/project/test' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be a hash
    And the project should contains environment 'ec2'

  Scenario: Get servers list
    When I send GET '/v2.0/servers' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array
    And the list should be saved

  @ignore @long
  Scenario: Create new server with bootstraping
    When I send POST '/v2.0/server' query with params '{"project": "test", "deploy_env": "test"}'
    Then response should be '200'

  Scenario: Create new server without bootstraping
    When I send POST '/v2.0/server' query with params '{ "project": "test", "deploy_env": "test", "without_bootstrap": true }'
    Then response should be '200'

  Scenario: Get new servers list
    When I send GET '/v2.0/servers' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array
    And the list should contains new server

  Scenario: reserve new server
    When I reserve new server
    Then response should be '201'

  @ignore
  Scenario: get reserved servers list
    When I send GET '/v2.0/servers?reserved=true' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array
    And the list should contains reserved server

  Scenario: Pause server
    When I pause new server
    Then response should be '200'
    And sleep '20' seconds

  Scenario: Unpause server
    When I unpause new server
    Then response should be '200'
    And sleep '20' seconds

  Scenario: Deploy server
    When I deploy new server
    Then response should be '200'

  Scenario: Delete server
    When I delete new server
    Then response should be '200'
