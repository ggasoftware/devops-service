Then(/^response should contains ec2 groups elements$/) do
  obj = JSON.parse(last_response.body)
  assert obj.key?("default"), "Group 'default' is missing"
  if obj.key?("default")
    d = obj["default"]
    %w{description id rules}.each do |k|
      assert d.key?(k), "Group 'default' has no '#{k}' field"
    end
    assert d["rules"].is_a?(Array), "Field 'rules' should be an array"
  end
end

Then(/^response should contains openstack groups elements$/) do
  obj = JSON.parse(last_response.body)
  assert obj.key?("default"), "Group 'default' is missing"
  if obj.key?("default")
    d = obj["default"]
    %w{description rules}.each do |k|
      assert d.key?(k), "Group 'default' has no '#{k}' field"
    end
    assert d["rules"].is_a?(Array), "Field 'rules' should be an array"
  end
end

