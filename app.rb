require 'time'
require 'json'
require 'net/http'
require "functions_framework"

FunctionsFramework.http("status") do |request|
  time_now = Time.now
  bearer_token = ENV["BEARER_TOKEN"]
  params = { "max_results" => 9, "tweet.fields" => "created_at" }
  headers = { "Authorization" => "Bearer #{bearer_token}" }
  uri = URI("https://api.twitter.com/2/users/919284817/tweets")

  uri.query = URI.encode_www_form(params)
  response = Net::HTTP.get_response(uri, headers)
  return 421 unless response.is_a?(Net::HTTPSuccess)

  payload = {updates: []}
  JSON.parse(response.body)['data'].each do |row|
    mins = (time_now - Time.parse(row['created_at'])).to_i / 60
    payload[:updates] << {mins: mins, time: row['created_at'], text: row['text']}
  end
  payload
end
