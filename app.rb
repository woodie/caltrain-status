require 'time'
require 'json'
require 'httparty'

FunctionsFramework.http("status") do |request|
  time_now = Time.now
  bearer_token = ENV["BEARER_TOKEN"]
  query = { "max_results" => 9, "tweet.fields" => "created_at" }
  headers = { "Authorization" => "Bearer #{bearer_token}" }
  endpoint_url = "https://api.twitter.com/2/users/919284817/tweets"

  resp = HTTParty.get(endpoint_url, query: query, headers: headers)
  return 421 if resp.code != 200

  response = {updates: []}
  JSON.parse(resp.body)['data'].each do |row|
    mins = (time_now - Time.parse(row['created_at'])).to_i / 60
    response[:updates] << {mins: mins, time: row['created_at'], text: row['text']}
  end
  response
end
