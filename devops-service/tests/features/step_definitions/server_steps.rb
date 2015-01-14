Then(/^the project should contains environment '(\w+)'$/) do |env|
  body = JSON.parse(last_response.body)
  assert !body["deploy_envs"].detect{|e| e["identifier"] == env}.nil?, "Project has no environment '#{env}'"
end

Then(/^the list should be saved$/) do
  body = JSON.parse(last_response.body)
  $test_hash[:servers_list] = body
end

Then(/^the list should contains new server$/) do
  body = JSON.parse(last_response.body)
  $test_hash[:new_server] = (body.map{|s| s["chef_node_name"]} - $test_hash[:servers_list].map{|s| s["chef_node_name"]}).first
  assert !$test_hash[:new_server].nil?, "New element in servers list not found"
end

When(/^I reserve new server$/) do
  steps %{
    When I send POST '/v2.0/server/#{$test_hash[:new_server]}/reserve' query with params ''
  }
end

When(/^I pause new server$/) do
  steps %{
    When I send POST '/v2.0/server/#{$test_hash[:new_server]}/pause' query with params ''
  }
end

When(/^I unpause new server$/) do
  steps %{
    When I send POST '/v2.0/server/#{$test_hash[:new_server]}/unpause' query with params ''
  }
end

When(/^I deploy new server$/) do
  steps %{
    When I send POST '/v2.0/deploy' query with params '{ "names": ["#{$test_hash[:new_server]}"] }'
  }
end

When(/^I delete new server$/) do
  steps %{
    When I send POST '/v2.0/deploy' query with params '{ "names": ["#{$test_hash[:new_server]}"] }'
  }
end

Then(/^sleep '(\d+)' seconds$/) do |s|
  sleep(s.to_i)
end
