@filter @image @project
Feature: Filters

  @openstack
  Scenario: Get list of openstack image filters
    When I send GET '/v2.0/filter/openstack/images' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array
    And the array elements should be strings

  @openstack
  Scenario: Get filter list of openstack provider without 'Accept' header
    When I send GET '/v2.0/filter/openstack/images' query without headers 'Accept'
    Then response should be '406'

  @ec2
  Scenario: Get list of ec2 image filters
    When I send GET '/v2.0/filter/ec2/images' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array
    And the array elements should be strings

  @ec2
  Scenario: Get filter list of ec2 provider without 'Accept' header
    When I send GET '/v2.0/filter/ec2/images' query without headers 'Accept'
    Then response should be '406'

  Scenario: Get filter list of unknown provider
    When I send GET '/v2.0/filter/foo/images' query
    Then response should be '404'

  Scenario: Get filter list of unknown provider without 'Accept' header
    When I send GET '/v2.0/filter/foo/images' query without headers 'Accept'
    Then response should be '406'

  Scenario: Get filter list of unknown provider without privileges
    When I send GET '/v2.0/filter/foo/images' query with user without privileges
    Then response should be '401'
