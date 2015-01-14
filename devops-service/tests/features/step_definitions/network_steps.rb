Then(/^response array should be empty or contains elements like:$/) do |string|
  src = JSON.parse(string).first
  array = JSON.parse(last_response.body)
  if array.empty?
    assert true
  else
    array.each do |e|
      src.each do |key, value|
        assert e.key?(key), "Element #{e.inspect} has no key '#{key}'"
      end
    end
  end
end

