DEFAULT_HEADERS = {
  'Content-Type' => 'application/json',
  'Accept' => 'application/json'
}
When(/^I send GET '(.*)' query$/) do |path|
  get(path, {}, DEFAULT_HEADERS)
end

When(/^I send GET '(.*)' query with user without privileges$/) do |path|
  get_without_privileges(path, {}, DEFAULT_HEADERS)
end

When(/^I send GET '(.*)' query without headers '(.*)'$/) do |path, hs|
  buf = hs.split(",").map{|e| e.strip}
  headers = {}
  DEFAULT_HEADERS.each{|h, v| headers[h] = v unless buf.include?(h)}
  get(path, {}, headers)
end

When(/^I send POST '(.*)' query with params '(.*)'$/) do |path, params|
  if params == ''
    p = Hash.new
  else
    p = JSON.parse params
  end
  res = post(path, p, DEFAULT_HEADERS)
end

When(/^I send POST '(.*)' query with JSON body$/) do |path, body|
  JSON.parse(body) unless body.strip.empty?
  res = post_body(path, body, DEFAULT_HEADERS)
end

When(/^I send POST '(.*)' query with JSON body without header '(.*)'$/) do |path, hs, body|
  JSON.parse(body) unless body.strip.empty?
  headers = DEFAULT_HEADERS.select{|h, v| h != hs}
  res = post_body(path, body, headers)
end

When(/^I send POST '(.*)' query with JSON body with user without privileges$/) do |path, body|
  JSON.parse(body) unless body.strip.empty?
  res = post_without_privileges(path, body, DEFAULT_HEADERS)
end

When(/^I send DELETE '(.*)' query$/) do |path|
  delete(path, {}, DEFAULT_HEADERS)
end

When(/^I send DELETE '(.*)' query with JSON body$/) do |path, body|
  JSON.parse(body) unless body.strip.empty?
  res = delete_body(path, body, DEFAULT_HEADERS)
end

When(/^I send DELETE '(.*)' query without header '(.*)'$/) do |path, hs|
  headers = DEFAULT_HEADERS.select{|h, v| h != hs}
  puts headers
  res = delete_body(path, nil, headers)
end

When(/^I send DELETE '(.*)' query with JSON body without header '(.*)'$/) do |path, hs, body|
  JSON.parse(body) unless body.strip.empty?
  headers = DEFAULT_HEADERS.select{|h, v| h != hs}
  res = delete_body(path, body, headers)
end

When(/^I send DELETE '(.*)' query with user without privileges$/) do |path|
  delete_without_privileges(path, {}, DEFAULT_HEADERS)
end

When(/^I send PUT '(.*)' query with body$/) do |path, body|
  res = put_body(path, body, DEFAULT_HEADERS)
end

When(/^I send PUT '(.*)' query with JSON body$/) do |path, body|
  JSON.parse(body) unless body.strip.empty?
  res = put_body(path, body, DEFAULT_HEADERS)
end

When(/^I send PUT '(.*)' query with user without privileges$/) do |path|
  put_without_privileges(path, {}, DEFAULT_HEADERS)
end

When(/^I send PUT '(.*)' query with body without header '(.*)'$/) do |path, hs, body|
  headers = DEFAULT_HEADERS.select{|h, v| h != hs}
  res = put_body(path, body, headers)
end

When(/^I send PUT '(.*)' query with JSON body without header '(.*)'$/) do |path, hs, body|
  JSON.parse(body) unless body.strip.empty?
  headers = DEFAULT_HEADERS.select{|h, v| h != hs}
  res = put_body(path, body, headers)
end

When(/^I send PUT '(.*)' query with JSON body with user without privileges$/) do |path, body|
  JSON.parse(body) unless body.strip.empty?
  res = put_without_privileges(path, body, DEFAULT_HEADERS)
end

Then(/^response should be '(\d+)'$/) do |code|
  assert(code.to_i == last_response.status, "Status is not #{code}, it is #{last_response.status}")
end

Then(/^response error should be "([^"]+)"$/) do |error_msg|
  json = JSON.parse(last_response.body)
  message = json['message']
  stripped_message = message.sub(/Project '\w+'. Deploy environment '\w+'. /, '')
  assert(error_msg == stripped_message, "Error message is not \n  #{error_msg}\nit is \n  #{stripped_message}")
end

Then(/^the Content\-Type header should include 'application\/json'$/) do
  assert last_response.header.contenttype.include?("application/json"), "Response has no header 'Content-Type' with 'application/json'"
end

