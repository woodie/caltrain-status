require "time"
require "json"
require "net/http"

class Status
  def initialize bearer_token
    @bearer_token = bearer_token
  end

  OPTS_HEADERS = {
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Methods" => "GET",
    "Access-Control-Allow-Headers" => "Content-Type",
    "Access-Control-Max-Age" => "3600"
  }

  CORS_HEADERS = {
    "Access-Control-Allow-Origin" => "*",
    "Content-type" => "application/json; charset=utf-8"
  }

  def message(train_id)
    @response ||= status_tweets
    return @response = nil unless @response.is_a?(Net::HTTPSuccess)

    JSON.parse(@response.body)["data"].each do |row|
      return "" if (Time.now - Time.parse(row["created_at"])).to_i > 30000

      fallback = ""
      parts = row["text"].split
      if parts.size > 1 && parts[0] == "Train" && parts[1] == train_id
        return row["text"]
      elsif fallback.empty? && parts[0] != "Train"
        return row["text"]
      end
    end
    ""
  end

  private

  def status_tweets
    api_params = {"max_results" => 20, "tweet.fields" => "created_at"}
    api_headers = {"Authorization" => "Bearer #{@bearer_token}"}
    uri = URI("https://api.twitter.com/2/users/919284817/tweets")
    uri.query = URI.encode_www_form(api_params)
    Net::HTTP.get_response(uri, api_headers)
  end
end
