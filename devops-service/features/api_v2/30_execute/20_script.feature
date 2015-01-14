@script
Feature: Run script

  Scenario: Run script
    When I send POST '/v2.0/script/run/cucumber_test_script' query with JSON body
    """
    {
      "nodes": [
        "devops-webapp_dev"
      ]
    }
    """
    Then response should be '200'
