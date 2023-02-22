require "time"
require "json"
require "net/http"
require "nokogiri"

class Status
  STALE_SECONDS = 36000 # 10 hours
  REFRESH_SECONDS = 600 # 10 minutes
  FALLBACK_TIME = Time.at(0)
  STATUS_FILE = "/tmp/status.json"

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

  def check
    response = status_page
    return nil unless response.is_a?(Net::HTTPSuccess)

    File.write(STATUS_FILE, JSON.dump({time: FALLBACK_TIME})) unless File.exist?(STATUS_FILE)
    file_time = Time.parse(JSON.parse(File.read(STATUS_FILE))["time"])
    feed_time = Time.parse(extract_data(response.body)["time"])
    if file_time < feed_time
      File.write(STATUS_FILE, JSON.dump({time: feed_time}))
      uri = URI("https://next-caltrain-pwa.appspot.com/scrape")
      Net::HTTP.get_response(uri).is_a?(Net::HTTPSuccess)
    end
  end

  def message(train_id)
    @response = status_page unless @response && @refresh_time > Time.now
    return @response = nil unless @response.is_a?(Net::HTTPSuccess)

    fallback = ""
    combo = train_id.to_i.even? ? "SB#{train_id}" : "NB#{train_id}"
    extract_data(@response.body)["data"].each do |row|
      return fallback if (Time.now - Time.parse(row["created_at"])).to_i > STALE_SECONDS

      parts = row["text"].split
      next unless parts.size > 1 && parts[0].size > 1

      if parts[0] == combo || row["text"].start_with?("Train #{train_id} ")
        return row["text"]
      elsif fallback.empty? && parts[0] != "NB" && parts[0] != "SB" && parts[0] != "Train"
        fallback = row["text"]
      end
    end
    fallback
  end

  private

  def status_page
    @refresh_time = Time.now + REFRESH_SECONDS
    uri = URI("https://www.caltrain.com/alerts?active_tab=service_alerts_tab")
    Net::HTTP.get_response(uri)
  end

  def extract_data(html)
    document = Nokogiri::HTML.parse(html)
    payload = {"data" => [], "time" => FALLBACK_TIME.to_s}
    tweets = document.at(".view-tweets")
    tweets.css(".views-row").each do |row|
      time = row.at("time").attributes["datetime"].value
      text = row.at("a").text
      payload["time"] = time if time > payload["time"]
      payload["data"] << {"created_at" => time, "text" => text}
    end
    payload
  end
end
