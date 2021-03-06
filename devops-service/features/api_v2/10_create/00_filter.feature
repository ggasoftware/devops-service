@filter @image @project
Feature: Filters

  @openstack
  Scenario: Add openstack image filter with user without privileges
    When I send PUT '/v2.0/filter/openstack/image' query with user without privileges
    Then response should be '401'

  @openstack
  Scenario: Add openstack image filter without header 'Accept'
    When I send PUT '/v2.0/filter/openstack/image' query with JSON body without header 'Accept'
    """
    [
      "08093b30-8393-42c3-8fb3-c4df56deb967"
    ]
    """
    Then response should be '406'

  @openstack
  Scenario: Add openstack image filter without header 'Content-Type'
    When I send PUT '/v2.0/filter/openstack/image' query with JSON body without header 'Content-Type'
    """
    [
      "08093b30-8393-42c3-8fb3-c4df56deb967"
    ]
    """
    Then response should be '415'

  @openstack
  Scenario: Add openstack image filter, invalid body: empty
    When I send PUT '/v2.0/filter/openstack/image' query with JSON body
    """
    """
    Then response should be '400'

  @openstack
  Scenario: Add openstack image filter, invalid body: hash
    When I send PUT '/v2.0/filter/openstack/image' query with JSON body
    """
    {
      "foo": "foo"
    }
    """
    Then response should be '400'

  @openstack
  Scenario: Add openstack image filter, invalid body: element is hash
    When I send PUT '/v2.0/filter/openstack/image' query with JSON body
    """
    [{
      "foo": "foo"
    }]
    """
    Then response should be '400'

  @openstack
  Scenario: Add openstack image filter, invalid body: element is array
    When I send PUT '/v2.0/filter/openstack/image' query with JSON body
    """
    [
      []
    ]
    """
    Then response should be '400'

  @openstack
  Scenario: Add openstack image filter, invalid body: element is null
    When I send PUT '/v2.0/filter/openstack/image' query with JSON body
    """
    [
      null
    ]
    """
    Then response should be '400'

  @openstack
  Scenario: Add openstack image filter
    When I send PUT '/v2.0/filter/openstack/image' query with JSON body
    """
    [
      "08093b30-8393-42c3-8fb3-c4df56deb967"
    ]
    """
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an object
    And the object should contains key 'images' with array and array should contains strings '08093b30-8393-42c3-8fb3-c4df56deb967'

  @openstack
  Scenario: Add openstack image filter with invalid JSON
    When I send PUT '/v2.0/filter/openstack/image' query with body
    """
    [
      "08093b30-8393-42c3-8fb3-c4df56deb967",
    ]
    """
    Then response should be '400'

  @ec2
  Scenario: Add ec2 image filter with user without privileges
    When I send PUT '/v2.0/filter/ec2/image' query with user without privileges
    Then response should be '401'

  @ec2
  Scenario: Add ec2 image filter without header 'Accept'
    When I send PUT '/v2.0/filter/ec2/image' query with JSON body without header 'Accept'
    """
    [
      "ami-63071b0a"
    ]
    """
    Then response should be '406'

  @ec2
  Scenario: Add ec2 image filter without header 'Content-Type'
    When I send PUT '/v2.0/filter/ec2/image' query with JSON body without header 'Content-Type'
    """
    [
      "ami-63071b0a"
    ]
    """
    Then response should be '415'

  @ec2
  Scenario: Add ec2 image filter, invalid body: empty
    When I send PUT '/v2.0/filter/ec2/image' query with JSON body
    """
    """
    Then response should be '400'

  @ec2
  Scenario: Add ec2 image filter, invalid body: hash
    When I send PUT '/v2.0/filter/ec2/image' query with JSON body
    """
    {
      "foo": "foo"
    }
    """
    Then response should be '400'

  @ec2
  Scenario: Add ec2 image filter, invalid body: element is hash
    When I send PUT '/v2.0/filter/ec2/image' query with JSON body
    """
    [{
      "foo": "foo"
    }]
    """
    Then response should be '400'

  @ec2
  Scenario: Add ec2 image filter, invalid body: element is array
    When I send PUT '/v2.0/filter/ec2/image' query with JSON body
    """
    [
      []
    ]
    """
    Then response should be '400'

  @ec2
  Scenario: Add ec2 image filter, invalid body: element is null
    When I send PUT '/v2.0/filter/ec2/image' query with JSON body
    """
    [
      null
    ]
    """
    Then response should be '400'

  @ec2
  Scenario: Add ec2 image filter
    When I send PUT '/v2.0/filter/ec2/image' query with JSON body
    """
    [
      "ami-63071b0a"
    ]
    """
    Then response should be '200'
    And the Content-Type header should include 'application/json'
    And the JSON response should be an object
    And the object should contains key 'images' with array and array should contains strings 'ami-63071b0a'

  @ec2
  Scenario: Add ec2 image filter with invalid JSON
    When I send PUT '/v2.0/filter/ec2/image' query with body
    """
    [
      "ami-63071b0a",
    ]
    """
    Then response should be '400'

