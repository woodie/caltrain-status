require "functions_framework"
require 'open-uri'
require 'nokogiri'
require 'time'

URL = 'https://www.caltrain.com/alerts?active_tab=service_alerts_tab'

FunctionsFramework.http("status") do |request|
  begin
    html = URI.open(URL)
  rescue OpenURI::HTTPError => error
    return 404
  end
  document = Nokogiri::HTML.parse(html)

  time_now = Time.now
  response = {updates: []}
  tweets = document.at('.view-tweets')
  tweets.css('.views-row').each do |row|
    time = row.at('time').attributes['datetime'].value
    mins =  (time_now - Time.parse(time)).to_i
    text = row.at('a').text
    response[:updates] << {mins: mins, time: time, text: text}
  end
  response
end
