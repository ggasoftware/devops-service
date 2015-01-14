@project
Feature: create project

  @openstack
  Scenario: Create project test_openstack
    When I send POST '/v2.0/project' query with JSON body
    """
    {
      "deploy_envs": [
        {
          "identifier": "test",
          "run_list": [],
          "expires": null,
          "provider": "openstack",
          "users": [
            "test"
          ],
          "flavor": "as_long_as_image",
          "image": "08093b30-8393-42c3-8fb3-c4df56deb967",
          "subnets": [
            "private"
          ],
          "groups": [
            "default"
          ]
        }
      ],
      "name": "test_openstack"
    }
    """
    Then response should be '201'

  @ec2
  Scenario: Create project test_ec2
    When I send POST '/v2.0/project' query with JSON body
    """
    {
      "deploy_envs": [
        {
          "identifier": "test",
          "run_list": [],
          "expires": null,
          "provider": "ec2",
          "users": [
            "test"
          ],
          "flavor": "m1.small",
          "image": "ami-63071b0a",
          "subnets": [],
          "groups": [
            "default"
          ]
        }
      ],
      "name": "test_ec2"
    }
    """
    Then response should be '201'

