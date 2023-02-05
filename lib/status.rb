require "time"
require "json"
require "net/http"
require "nokogiri"

class Status
  STALE_SECONDS = 36000 # 10 hours
  REFRESH_SECONDS = 600 # 10 minutes

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

  def initialize(bearer_token = "")
    @bearer_token = bearer_token
    @refresh_time = Time.now
  end

  def message(train_id)
    @response = status_page unless @response && @refresh_time > Time.now
    return @response = nil unless @response.is_a?(Net::HTTPSuccess)

    fallback = ""
    combo = train_id.to_i.even? ? "SB#{train_id}" : "NB#{train_id}"
    # JSON.parse(@response.body)["data"].each do |row|
    extract_data(@response.body)["data"].each do |row|
      return fallback if (Time.now - Time.parse(row["created_at"])).to_i > STALE_SECONDS

      parts = row["text"].split
      next unless parts.size > 1 && parts[0].size > 1

      if parts[0] == combo || row["text"].start_with?("Train #{train_id} ")
        return row["text"]
      elsif fallback.empty? && (parts[0][1] != "B" && parts[0].size == 5) && parts[0] != "Train"
        fallback = row["text"]
      end
    end
    fallback
  end

  private

  def status_tweets
    @refresh_time = Time.now + REFRESH_SECONDS
    api_params = {"max_results" => 20, "tweet.fields" => "created_at"}
    api_headers = {"Authorization" => "Bearer #{@bearer_token}"}
    uri = URI("https://api.twitter.com/2/users/919284817/tweets")
    uri.query = URI.encode_www_form(api_params)
    Net::HTTP.get_response(uri, api_headers)
  end

  def status_page
    @refresh_time = Time.now + REFRESH_SECONDS
    uri = URI("https://www.caltrain.com/alerts?active_tab=service_alerts_tab")
    Net::HTTP.get_response(uri)
  end

  def extract_data(html)
    document = Nokogiri::HTML.parse(html)
    payload = {"data" => []}
    tweets = document.at(".view-tweets")
    tweets.css(".views-row").each do |row|
      time = row.at("time").attributes["datetime"].value
      text = row.at("a").text
      payload["data"] << {"created_at" => time, "text" => text}
    end
    payload
  end
end
