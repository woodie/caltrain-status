require 'time'
require 'json'
require 'net/http'
require "functions_framework"

MAX = 600

FunctionsFramework.http("status") do |request|
  options_headers = {
    "Access-Control-Allow-Origin"  => "*",
    "Access-Control-Allow-Methods" => "GET",
    "Access-Control-Allow-Headers" => "Content-Type",
    "Access-Control-Max-Age"       => "3600"
  }
  return [204, options_headers, []] if request.options?

  bearer_token = ENV["BEARER_TOKEN"]
  params = { "max_results" => 9, "tweet.fields" => "created_at" }
  headers = { "Authorization" => "Bearer #{bearer_token}" }
  uri = URI("https://api.twitter.com/2/users/919284817/tweets")
  uri.query = URI.encode_www_form(params)
  response = Net::HTTP.get_response(uri, headers)
  return [500, {}, ["Something went wrong."]] unless response.is_a?(Net::HTTPSuccess)

  train = request.params['train'] || nil
  time_now = Time.now
  payload = {selected: "", updates: []}
  JSON.parse(response.body)['data'].each do |row|
    mins = (time_now - Time.parse(row['created_at'])).to_i / 60
    parts = row['text'].split
    payload[:updates] << {mins: mins, time: row['created_at'], text: row['text']}
    if payload[:selected].empty? && mins < MAX && parts.size > 1 && parts[0] == 'Train' && parts[1] == train
      payload[:selected] = row['text']
    end
  end
  first = payload[:updates][0]
  if payload[:selected].empty? && first[:mins] < MAX && !first[:text].start_with?('Train')
    payload[:selected] = first[:text]
  end
  cors_headers = {
    "Access-Control-Allow-Origin" => "*",
    "Content-type" => "application/json; charset=utf-8"
  }
  [200, cors_headers, [payload.to_json]]
end
