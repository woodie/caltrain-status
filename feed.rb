#!/usr/bin/env ruby

require 'time'
require 'json'
require 'typhoeus'

def status_list
  time_now = Time.now
  bearer_token = ENV["BEARER_TOKEN"]
  endpoint_url = "https://api.twitter.com/2/users/919284817/tweets"
  options = { method: 'get',
    params:  { "max_results" => 9, "tweet.fields" => "created_at" },
    headers: { "Authorization" => "Bearer #{bearer_token}" }
  }
  request = Typhoeus::Request.new(endpoint_url, options)
  resp = request.run

  response = {updates: []} 
  JSON.parse(resp.body)['data'].each do |row|
    mins = (time_now - Time.parse(row['created_at'])).to_i
    response[:updates] << {mins: mins, time: row['created_at'], text: row['text']}
  end
  response
end

puts JSON.pretty_generate(status_list)
