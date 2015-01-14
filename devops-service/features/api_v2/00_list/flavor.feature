@flavor
Feature: Flavors

  @openstack
  Scenario: Get list of openstack flavors
    When I send GET '/v2.0/flavors/openstack' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array
    And response array should contains elements like:
    """
    [
      {
        "id": "flavor_id",
        "v_cpus": "v_cpus",
        "ram": "ram",
        "disk": "disk"
      }
    ]
    """

  @ec2
  Scenario: Get list of ec2 flavors
    When I send GET '/v2.0/flavors/ec2' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array
    And response array should contains elements like:
    """
    [
      {
        "id": "t1.micro",
        "cores": 2,
        "disk": 0,
        "name": "Micro Instance",
        "ram": 613
      }
    ]
    """

  @static
  Scenario: Get list of static flavors
    When I send GET '/v2.0/flavors/static' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array
    And response array should be empty

  @static
  Scenario: Get flavors list of static provider without 'Accept' header
    When I send GET '/v2.0/flavors/static' query without headers 'Accept'
    Then response should be '406'

  Scenario: Get flavors list of unknown provider
    When I send GET '/v2.0/flavors/foo' query
    Then response should be '404'

  Scenario: Get flavors list of unknown provider without 'Accept' header
    When I send GET '/v2.0/flavors/foo' query without headers 'Accept'
    Then response should be '406'

  Scenario: Get flavors list of unknown provider without privileges
    When I send GET '/v2.0/flavors/foo' query with user without privileges
    Then response should be '401'
