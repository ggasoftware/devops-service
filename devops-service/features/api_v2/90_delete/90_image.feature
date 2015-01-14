@image @project
Feature: delete image

  @openstack
  Scenario: Delete openstack image with user without privileges
    When I send DELETE '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query with user without privileges
    Then response should be '401'

  @openstack
  Scenario: Delete openstack image without header 'Accept'
    When I send DELETE '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query without header 'Accept'
    Then response should be '406'

  @openstack
  Scenario: Delete openstack image
    When I send DELETE '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an object
    And response should be JSON object like:
    """
    {
      "message" : "Image '08093b30-8393-42c3-8fb3-c4df56deb967' has been removed"
    }
    """

  @ec2
  Scenario: Delete ec2 image with user without privileges
    When I send DELETE '/v2.0/image/ami-63071b0a' query with user without privileges
    Then response should be '401'

  @ec2
  Scenario: Delete ec2 image without header 'Accept'
    When I send DELETE '/v2.0/image/ami-63071b0a' query without header 'Accept'
    Then response should be '406'

  @ec2
  Scenario: Delete ec2 image
    When I send DELETE '/v2.0/image/ami-63071b0a' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an object
    And response should be JSON object like:
    """
    {
      "message" : "Image 'ami-63071b0a' has been removed"
    }
    """

  Scenario: Delete unknown image
    When I send DELETE '/v2.0/image/foo' query
    Then response should be '404'
