@group
Feature: Groups

  @openstack
  Scenario: Get list of openstack groups
    When I send GET '/v2.0/groups/openstack' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an object
    And response should contains openstack groups elements

  @ec2
  Scenario: Get list of ec2 groups
    When I send GET '/v2.0/groups/ec2' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an object
    And response should contains ec2 groups elements

  @static
  Scenario: Get list of static groups
    When I send GET '/v2.0/groups/static' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an object
    And response object should be empty

  @static
  Scenario: Get groups list of static provider without 'Accept' header
    When I send GET '/v2.0/groups/static' query without headers 'Accept'
    Then response should be '406'

  Scenario: Get groups list of unknown provider
    When I send GET '/v2.0/groups/foo' query
    Then response should be '404'

  Scenario: Get groups list of unknown provider without 'Accept' header
    When I send GET '/v2.0/groups/foo' query without headers 'Accept'
    Then response should be '406'

  Scenario: Get groups list of unknown provider without privileges
    When I send GET '/v2.0/groups/foo' query with user without privileges
    Then response should be '401'
