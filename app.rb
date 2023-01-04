require "time"
require "json"
require "net/http"
require "functions_framework"

FunctionsFramework.http("status") do |request|
  options_headers = {
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Methods" => "GET",
    "Access-Control-Allow-Headers" => "Content-Type",
    "Access-Control-Max-Age" => "3600"
  }
  return [204, options_headers, []] if request.options?

  api_params = {"max_results" => 20, "tweet.fields" => "created_at"}
  api_headers = {"Authorization" => "Bearer #{ENV["BEARER_TOKEN"]}"}
  uri = URI("https://api.twitter.com/2/users/919284817/tweets")
  uri.query = URI.encode_www_form(api_params)
  response = Net::HTTP.get_response(uri, api_headers)
  return [500, {}, ["Something went wrong."]] unless response.is_a?(Net::HTTPSuccess)

  cors_headers = {
    "Access-Control-Allow-Origin" => "*",
    "Content-type" => "application/json; charset=utf-8"
  }
  train_id = request.params["train"] || nil
  fallback = ""
  JSON.parse(response.body)["data"].each do |row|
    break if (Time.now - Time.parse(row["created_at"])).to_i > 30000

    parts = row["text"].split
    if parts.size > 1 && parts[0] == "Train" && parts[1] == train_id
      return [200, cors_headers, [{message: row["text"]}.to_json]]
    elsif fallback.empty? && parts[0] != "Train"
      fallback = row["text"]
    end
  end
  [200, cors_headers, [{message: fallback}.to_json]]
end
