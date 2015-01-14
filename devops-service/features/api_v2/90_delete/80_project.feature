@project
Feature: delete project

  @openstack
  Scenario: Delete openstack project with user without privileges
    When I send DELETE '/v2.0/project/test_openstack' query with user without privileges
    Then response should be '401'

  @openstack
  Scenario: Delete openstack project without header 'Accept'
    When I send DELETE '/v2.0/project/test_openstack' query without header 'Accept'
    Then response should be '406'

  @openstack
  Scenario: Delete openstack project
    When I send DELETE '/v2.0/project/test_openstack' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an object
    And response should be JSON object like:
    """
    {
      "message" : "Project 'test_openstack' is deleted"
    }
    """

  @ec2
  Scenario: Delete ec2 project with user without privileges
    When I send DELETE '/v2.0/project/test_ec2' query with user without privileges
    Then response should be '401'

  @ec2
  Scenario: Delete ec2 project without header 'Accept'
    When I send DELETE '/v2.0/project/test_ec2' query without header 'Accept'
    Then response should be '406'

  @ec2
  Scenario: Delete ec2 project
    When I send DELETE '/v2.0/project/test_ec2' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an object
    And response should be JSON object like:
    """
    {
      "message" : "Project 'test_ec2' is deleted"
    }
    """

  Scenario: Delete unknown project
    When I send DELETE '/v2.0/project/foo' query
    Then response should be '404'

