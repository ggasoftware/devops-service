@image @project
Feature: Update images

  @openstack
  Scenario: Update openstack image with ec2 provider
    When I send PUT '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query with JSON body
    """
    {
      "provider": "ec2",
      "name": "freebsd-10.0",
      "remote_user": "root",
      "bootstrap_template": "chef_freebsd",
      "id": "08093b30-8393-42c3-8fb3-c4df56deb967"
    }
    """
    Then response should be '400'

  @openstack
  Scenario: Update openstack image with invalid provider
    When I send PUT '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query with JSON body
    """
    {
      "provider": "foo",
      "name": "freebsd-10.0",
      "remote_user": "root",
      "bootstrap_template": "chef_freebsd",
      "id": "08093b30-8393-42c3-8fb3-c4df56deb967"
    }
    """
    Then response should be '400'

  @openstack
  Scenario: Update openstack image with invalid provider - array
    When I send PUT '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query with JSON body
    """
    {
      "provider": ["foo"],
      "name": "freebsd-10.0",
      "remote_user": "root",
      "bootstrap_template": "chef_freebsd",
      "id": "08093b30-8393-42c3-8fb3-c4df56deb967"
    }
    """
    Then response should be '400'

  @openstack
  Scenario: Update openstack image with invalid provider - hash
    When I send PUT '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query with JSON body
    """
    {
      "provider": {},
      "name": "freebsd-10.0",
      "remote_user": "root",
      "bootstrap_template": "chef_freebsd",
      "id": "08093b30-8393-42c3-8fb3-c4df56deb967"
    }
    """
    Then response should be '400'

  @openstack
  Scenario: Update openstack image with invalid name - hash
    When I send PUT '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query with JSON body
    """
    {
      "provider": "openstack",
      "name": {},
      "remote_user": "root",
      "bootstrap_template": "chef_freebsd",
      "id": "08093b30-8393-42c3-8fb3-c4df56deb967"
    }
    """
    Then response should be '400'

  @openstack
  Scenario: Update openstack image with invalid name - array
    When I send PUT '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query with JSON body
    """
    {
      "provider": "openstack",
      "name": [],
      "remote_user": "root",
      "bootstrap_template": "chef_freebsd",
      "id": "08093b30-8393-42c3-8fb3-c4df56deb967"
    }
    """
    Then response should be '400'

  @openstack
  Scenario: Update openstack image with invalid remote_user - hash
    When I send PUT '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query with JSON body
    """
    {
      "provider": "openstack",
      "name": "freebsd-10.0",
      "remote_user": {},
      "bootstrap_template": "chef_freebsd",
      "id": "08093b30-8393-42c3-8fb3-c4df56deb967"
    }
    """
    Then response should be '400'

  @openstack
  Scenario: Update openstack image with invalid remote_user - array
    When I send PUT '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query with JSON body
    """
    {
      "provider": "openstack",
      "name": "freebsd-10.0",
      "remote_user": [],
      "bootstrap_template": "chef_freebsd",
      "id": "08093b30-8393-42c3-8fb3-c4df56deb967"
    }
    """
    Then response should be '400'

  @openstack
  Scenario: Update openstack image with invalid bootstrap_template - array
    When I send PUT '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query with JSON body
    """
    {
      "provider": "openstack",
      "name": "freebsd-10.0",
      "remote_user": "root",
      "bootstrap_template": [],
      "id": "08093b30-8393-42c3-8fb3-c4df56deb967"
    }
    """
    Then response should be '400'

  @openstack
  Scenario: Update openstack image with invalid bootstrap_template - hash
    When I send PUT '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query with JSON body
    """
    {
      "provider": "openstack",
      "name": "freebsd-10.0",
      "remote_user": "root",
      "bootstrap_template": {},
      "id": "08093b30-8393-42c3-8fb3-c4df56deb967"
    }
    """
    Then response should be '400'

  @openstack
  Scenario: Update openstack image with invalid bootstrap_template - unknown
    When I send PUT '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query with JSON body
    """
    {
      "provider": "openstack",
      "name": "freebsd-10.0",
      "remote_user": "root",
      "bootstrap_template": "unknown",
      "id": "08093b30-8393-42c3-8fb3-c4df56deb967"
    }
    """
    Then response should be '400'

  @openstack
  Scenario: Update openstack image with invalid id - array
    When I send PUT '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query with JSON body
    """
    {
      "provider": "openstack",
      "name": "freebsd-10.0",
      "remote_user": "root",
      "bootstrap_template": "chef_freebsd",
      "id": []
    }
    """
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an object
    And response should be JSON object like:
    """
    {
      "message" : "Image '08093b30-8393-42c3-8fb3-c4df56deb967' has been updated"
    }
    """

  @openstack
  Scenario: Update openstack image with invalid id - hash
    When I send PUT '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query with JSON body
    """
    {
      "provider": "openstack",
      "name": "freebsd-10.0",
      "remote_user": "root",
      "bootstrap_template": "chef_freebsd",
      "id": {}
    }
    """
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an object
    And response should be JSON object like:
    """
    {
      "message" : "Image '08093b30-8393-42c3-8fb3-c4df56deb967' has been updated"
    }
    """

  @openstack
  Scenario: Update openstack image
    When I send PUT '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query with JSON body
    """
    {
      "provider": "openstack",
      "name": "freebsd-10.0",
      "remote_user": "root",
      "bootstrap_template": "chef_freebsd",
      "id": "08093b30-8393-42c3-8fb3-c4df56deb967"
    }
    """
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an object
    And response should be JSON object like:
    """
    {
      "message" : "Image '08093b30-8393-42c3-8fb3-c4df56deb967' has been updated"
    }
    """

  @ec2
  Scenario: Update ec2 image with openstack provider
    When I send PUT '/v2.0/image/ami-63071b0a' query with JSON body
    """
    {
      "provider": "openstack",
      "name": "test-ec2",
      "remote_user": "ec2-user",
      "bootstrap_template": null,
      "id": "ami-63071b0a"
    }
    """
    Then response should be '400'

  @ec2
  Scenario: Update ec2 image with invalid provider
    When I send PUT '/v2.0/image/ami-63071b0a' query with JSON body
    """
    {
      "provider": "foo",
      "name": "test-ec2",
      "remote_user": "ec2-user",
      "bootstrap_template": null,
      "id": "ami-63071b0a"
    }
    """
    Then response should be '400'

  @ec2
  Scenario: Update ec2 image with invalid provider - array
    When I send PUT '/v2.0/image/ami-63071b0a' query with JSON body
    """
    {
      "provider": ["foo"],
      "name": "test-ec2",
      "remote_user": "ec2-user",
      "bootstrap_template": null,
      "id": "ami-63071b0a"
    }
    """
    Then response should be '400'

  @ec2
  Scenario: Update ec2 image with invalid provider - hash
    When I send PUT '/v2.0/image/ami-63071b0a' query with JSON body
    """
    {
      "provider": {},
      "name": "test-ec2",
      "remote_user": "ec2-user",
      "bootstrap_template": null,
      "id": "ami-63071b0a"
    }
    """
    Then response should be '400'

  @ec2
  Scenario: Update ec2 image with invalid name - hash
    When I send PUT '/v2.0/image/ami-63071b0a' query with JSON body
    """
    {
      "provider": "ec2",
      "name": {},
      "remote_user": "ec2-user",
      "bootstrap_template": null,
      "id": "ami-63071b0a"
    }
    """
    Then response should be '400'

  @ec2
  Scenario: Update ec2 image with invalid name - array
    When I send PUT '/v2.0/image/ami-63071b0a' query with JSON body
    """
    {
      "provider": "ec2",
      "name": [],
      "remote_user": "ec2-user",
      "bootstrap_template": null,
      "id": "ami-63071b0a"
    }
    """
    Then response should be '400'

  @ec2
  Scenario: Update ec2 image with invalid remote_user - hash
    When I send PUT '/v2.0/image/ami-63071b0a' query with JSON body
    """
    {
      "provider": "ec2",
      "name": "test-ec2",
      "remote_user": {},
      "bootstrap_template": null,
      "id": "ami-63071b0a"
    }
    """
    Then response should be '400'

  @ec2
  Scenario: Update ec2 image with invalid remote_user - array
    When I send PUT '/v2.0/image/ami-63071b0a' query with JSON body
    """
    {
      "provider": "ec2",
      "name": "test-ec2",
      "remote_user": [],
      "bootstrap_template": null,
      "id": "ami-63071b0a"
    }
    """
    Then response should be '400'

  @ec2
  Scenario: Update ec2 image with invalid bootstrap_template - array
    When I send PUT '/v2.0/image/ami-63071b0a' query with JSON body
    """
    {
      "provider": "ec2",
      "name": "test-ec2",
      "remote_user": "ec2-user",
      "bootstrap_template": [],
      "id": "ami-63071b0a"
    }
    """
    Then response should be '400'

  @ec2
  Scenario: Update ec2 image with invalid bootstrap_template - hash
    When I send PUT '/v2.0/image/ami-63071b0a' query with JSON body
    """
    {
      "provider": "ec2",
      "name": "test-ec2",
      "remote_user": "ec2-user",
      "bootstrap_template": {},
      "id": "ami-63071b0a"
    }
    """
    Then response should be '400'

  @ec2
  Scenario: Update ec2 image with invalid bootstrap_template - unknown
    When I send PUT '/v2.0/image/ami-63071b0a' query with JSON body
    """
    {
      "provider": "ec2",
      "name": "test-ec2",
      "remote_user": "ec2-user",
      "bootstrap_template": "unknown",
      "id": "ami-63071b0a"
    }
    """
    Then response should be '400'

  @ec2
  Scenario: Update ec2 image with invalid id - array
    When I send PUT '/v2.0/image/ami-63071b0a' query with JSON body
    """
    {
      "provider": "ec2",
      "name": "test-ec2",
      "remote_user": "ec2-user",
      "bootstrap_template": null,
      "id": []
    }
    """
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an object
    And response should be JSON object like:
    """
    {
      "message" : "Image '08093b30-8393-42c3-8fb3-c4df56deb967' has been updated"
    }
    """

  @ec2
  Scenario: Update ec2 image with invalid id - hash
    When I send PUT '/v2.0/image/ami-63071b0a' query with JSON body
    """
    {
      "provider": "ec2",
      "name": "test-ec2",
      "remote_user": "ec2-user",
      "bootstrap_template": null,
      "id": {}
    }
    """
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an object
    And response should be JSON object like:
    """
    {
      "message" : "Image '08093b30-8393-42c3-8fb3-c4df56deb967' has been updated"
    }
    """

  @ec2
  Scenario: Update ec2 image
    When I send PUT '/v2.0/image/ami-63071b0a' query with JSON body
    """
    {
      "provider": "ec2",
      "name": "test-ec2",
      "remote_user": "ec2-user",
      "bootstrap_template": null,
      "id": "ami-63071b0a"
    }
    """
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an object
    And response should be JSON object like:
    """
    {
      "message" : "Image '08093b30-8393-42c3-8fb3-c4df56deb967' has been updated"
    }
    """
