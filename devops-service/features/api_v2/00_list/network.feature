@network
Feature: Networks

  @openstack
  Scenario: Get list of openstack networks
    When I send GET '/v2.0/networks/openstack' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array
    And response array should contains elements like:
    """
    [
      {
        "cidr": "192.168.0.0/16",
        "name": "private",
        "id": "net_id"
      }
    ]
    """

  @ec2
  Scenario: Get list of ec2 networks
    When I send GET '/v2.0/networks/ec2' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array
    And response array should contains elements like:
    """
    [
      {
        "cidr": "192.168.0.0/16",
        "name": "private",
        "zone": "net_zone",
        "vpcId": "vpcId",
        "subnetId": "subnetId"
      }
    ]
    """

  @static
  Scenario: Get list of static networks
    When I send GET '/v2.0/networks/static' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array
    And response array should be empty

  @static
  Scenario: Get networks list of static provider without 'Accept' header
    When I send GET '/v2.0/networks/static' query without headers 'Accept'
    Then response should be '406'

  Scenario: Get networks list of unknown provider
    When I send GET '/v2.0/networks/foo' query
    Then response should be '404'

  Scenario: Get networks list of unknown provider without 'Accept' header
    When I send GET '/v2.0/networks/foo' query without headers 'Accept'
    Then response should be '406'

  Scenario: Get networks list of unknown provider without privileges
    When I send GET '/v2.0/networks/foo' query with user without privileges
    Then response should be '401'
