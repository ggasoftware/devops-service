@image @project
Feature: Manage images

  Scenario: Get list of all images
    When I send GET '/v2.0/images' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array
    And response array should contains elements like:
    """
    [
      {
        "provider": "foo_provider",
        "name": "foo_name",
        "remote_user": "foo_user",
        "bootstrap_template": "foo_template",
        "id": "foo_id"
      }
    ]
    """

  Scenario: Get list of all images without header 'Accept'
    When I send GET '/v2.0/images' query without headers 'Accept'
    Then response should be '406'

  Scenario: Get list of all images without privileges
    When I send GET '/v2.0/images' query with user without privileges
    Then response should be '401'

  Scenario: Get list of all images - invalid path
    When I send GET '/v2.0/images/foo' query
    Then response should be '404'

  @openstack
  Scenario: Get list of openstack images
    When I send GET '/v2.0/images?provider=openstack' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array
    And response array should contains elements like:
    """
    [
      {
        "provider": "foo_provider",
        "name": "foo_name",
        "remote_user": "foo_user",
        "bootstrap_template": "foo_template",
        "id": "foo_id"
      }
    ]
    """

  @openstack
  Scenario: Get list of openstack images (provider)
    When I send GET '/v2.0/images/provider/openstack' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array

  @openstack
  Scenario: Get list of openstack images (provider) without header 'Accept'
    When I send GET '/v2.0/images/provider/openstack' query without headers 'Accept'
    Then response should be '406'

  @openstack
  Scenario: Get images list of openstack without privileges
    When I send GET '/v2.0/images/provider/openstack' query with user without privileges
    Then response should be '401'

  @ec2
  Scenario: Get list of ec2 images
    When I send GET '/v2.0/images?provider=ec2' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array
    And response array should contains elements like:
    """
    [
      {
        "provider": "foo_provider",
        "name": "foo_name",
        "remote_user": "foo_user",
        "bootstrap_template": "foo_template",
        "id": "foo_id"
      }
    ]
    """

  @ec2
  Scenario: Get list of ec2 images (provider)
    When I send GET '/v2.0/images/provider/ec2' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an array

  @ec2
  Scenario: Get list of ec2 images (provider) without header 'Accept'
    When I send GET '/v2.0/images/provider/ec2' query without headers 'Accept'
    Then response should be '406'

  @ec2
  Scenario: Get images list of ec2 without privileges
    When I send GET '/v2.0/images/provider/ec2' query with user without privileges
    Then response should be '401'

  Scenario: Get list of images of unknown provider
    When I send GET '/v2.0/images/provider/foo' query
    Then response should be '404'

  Scenario: Get images list without privileges
    When I send GET '/v2.0/images' query with user without privileges
    Then response should be '401'

  Scenario: Get unknown image
    When I send GET '/v2.0/image/foo' query
    Then response should be '404'

  Scenario: Get unknown image without privileges
    When I send GET '/v2.0/image/foo' query with user without privileges
    Then response should be '401'

  @openstack
  Scenario: Create openstack image with ec2 provider
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create openstack image with invalid provider
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create openstack image with invalid provider - array
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create openstack image with invalid provider - hash
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create openstack image with invalid name - hash
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create openstack image with invalid name - array
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create openstack image with invalid remote_user - hash
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create openstack image with invalid remote_user - array
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create openstack image with invalid bootstrap_template - array
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create openstack image with invalid bootstrap_template - hash
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create openstack image with invalid bootstrap_template - unknown
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create openstack image with invalid id - array
    When I send POST '/v2.0/image' query with JSON body
    """
    {
      "provider": "openstack",
      "name": "freebsd-10.0",
      "remote_user": "root",
      "bootstrap_template": "chef_freebsd",
      "id": []
    }
    """
    Then response should be '400'

  @openstack
  Scenario: Create openstack image with invalid id - hash
    When I send POST '/v2.0/image' query with JSON body
    """
    {
      "provider": "openstack",
      "name": "freebsd-10.0",
      "remote_user": "root",
      "bootstrap_template": "chef_freebsd",
      "id": {}
    }
    """
    Then response should be '400'

  @openstack
  Scenario: Create openstack image
    When I send POST '/v2.0/image' query with JSON body
    """
    {
      "provider": "openstack",
      "name": "freebsd-10.0",
      "remote_user": "root",
      "bootstrap_template": "chef_freebsd",
      "id": "08093b30-8393-42c3-8fb3-c4df56deb967"
    }
    """
    Then response should be '201'
    And the Content-Type header should include 'application/json'

  @ec2
  Scenario: Create ec2 image with openstack provider
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create ec2 image with invalid provider
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create ec2 image with invalid provider - array
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create ec2 image with invalid provider - hash
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create ec2 image with invalid name - hash
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create ec2 image with invalid name - array
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create ec2 image with invalid remote_user - hash
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create ec2 image with invalid remote_user - array
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create ec2 image with invalid bootstrap_template - array
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create ec2 image with invalid bootstrap_template - hash
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create ec2 image with invalid bootstrap_template - unknown
    When I send POST '/v2.0/image' query with JSON body
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
  Scenario: Create ec2 image with invalid id - array
    When I send POST '/v2.0/image' query with JSON body
    """
    {
      "provider": "ec2",
      "name": "test-ec2",
      "remote_user": "ec2-user",
      "bootstrap_template": null,
      "id": []
    }
    """
    Then response should be '400'

  @ec2
  Scenario: Create ec2 image with invalid id - hash
    When I send POST '/v2.0/image' query with JSON body
    """
    {
      "provider": "ec2",
      "name": "test-ec2",
      "remote_user": "ec2-user",
      "bootstrap_template": null,
      "id": {}
    }
    """
    Then response should be '400'

  @ec2
  Scenario: Create ec2 image
    When I send POST '/v2.0/image' query with JSON body
    """
    {
      "provider": "ec2",
      "name": "test-ec2",
      "remote_user": "ec2-user",
      "bootstrap_template": null,
      "id": "ami-63071b0a"
    }
    """
    Then response should be '201'
    And the Content-Type header should include 'application/json'

  @ec2
  Scenario: Get info for single ec2 image
    When I send GET '/v2.0/image/ami-63071b0a' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an object
    And response should be JSON object like:
    """
    {
      "provider": "ec2",
      "name": "test-ec2",
      "remote_user": "ec2-user",
      "bootstrap_template": null,
      "id": "ami-63071b0a"
    }
    """

  @ec2
  Scenario: Get info for single ec2 image without headers 'Accept'
    When I send GET '/v2.0/image/ami-63071b0a' query without headers 'Accept'
    Then response should be '406'

  @ec2
  Scenario: Get ec2 image without privileges
    When I send GET '/v2.0/image/ami-63071b0a' query with user without privileges
    Then response should be '401'

  @openstack
  Scenario: Get info for single openstack image
    When I send GET '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an object
    And response should be JSON object like:
    """
    {
      "provider": "openstack",
      "name": "freebsd-10.0",
      "remote_user": "root",
      "bootstrap_template": "chef_freebsd",
      "id": "08093b30-8393-42c3-8fb3-c4df56deb967"
    }
    """

  @openstack
  Scenario: Get info for single openstack image without headers 'Accept'
    When I send GET '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query without headers 'Accept'
    Then response should be '406'

  @openstack
  Scenario: Get openstack image without privileges
    When I send GET '/v2.0/image/08093b30-8393-42c3-8fb3-c4df56deb967' query with user without privileges
    Then response should be '401'

  Scenario: Get info for single unknown image
    When I send GET '/v2.0/image/foo' query
    Then response should be '404'

  Scenario: Get image path
    When I send GET '/v2.0/image' query
    Then response should be '404'
