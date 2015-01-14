Then(/^response array should contains elements like:$/) do |string|
  src = JSON.parse(string).first
  array = JSON.parse(last_response.body)
  array.each do |e|
    src.each do |key, value|
      assert e.key?(key), "Element #{e.inspect} has no key '#{key}'"
    end
  end
end

Then(/^response array should be empty$/) do
  array = JSON.parse(last_response.body)
  assert array.empty?, "Array is not empty"
end

Then(/^response object should be empty$/) do
  obj = JSON.parse(last_response.body)
  assert obj.empty?, "Object is not empty"
end

Then(/^the JSON response should be an array$/) do
  body = JSON.parse(last_response.body)
  assert body.is_a?(Array), "Body is not an array: #{last_response.body}"
end

Then(/^the JSON response should be an object$/) do
  body = JSON.parse(last_response.body)
  assert body.is_a?(Hash), "Body is not an object"
end

Then(/^the array elements should be strings$/) do
  body = JSON.parse(last_response.body)
  body.each do |e|
    assert e.is_a?(String), "Array element is not a string"
  end
end

Then(/^response should be JSON object like:$/) do |string|
  src = JSON.parse(string)
  obj = JSON.parse(last_response.body)
  src.each do |key, value|
    assert obj.key?(key), "Object has no key '#{key}'"
  end
end

Then(/^the array should contains strings '(.*)'$/) do |string|
  buf = string.split(",")
  array = JSON.parse(last_response.body)
  buf.each do |v|
    assert array.include?(v), "Array should contains '#{v}'"
  end
end

Then(/^the array should not contains strings '(.*)'$/) do |string|
  buf = string.split(",")
  array = JSON.parse(last_response.body)
  buf.each do |v|
    assert !array.include?(v), "Array should not contains '#{v}'"
  end
end

Then(/^the object should contains key '(.*)' with array and array should contains strings '(.*)'$/) do |key, string|
  buf = string.split(",")
  obj = JSON.parse(last_response.body)
  assert obj.key?(key), "Object should has a key '#{key}'"
  assert obj[key].is_a?(Array), "Object should has an array '#{key}'"
  buf.each do |v|
    assert obj[key].include?(v), "'#{key}' array should contains '#{v}'"
  end
end

Then(/^the object should contains key '(.*)' with array and array should not contains strings '(.*)'$/) do |key, string|
  buf = string.split(",")
  obj = JSON.parse(last_response.body)
  assert obj.key?(key), "Object should has a key '#{key}'"
  assert obj[key].is_a?(Array), "Object should has an array '#{key}'"
  buf.each do |v|
    assert !obj[key].include?(v), "'#{key}' array should not contains '#{v}'"
  end
end

