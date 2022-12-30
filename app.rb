#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'
require 'time'
require 'json'

URL = 'https://www.caltrain.com/alerts?active_tab=service_alerts_tab'
status = []

begin
  html = URI.open(URL)
rescue OpenURI::HTTPError => error
  puts status.to_json
end  
document = Nokogiri::HTML.parse(html)

tweets = document.at('.view-tweets')
tweets.css('.views-row').each do |row|
  time = Time.parse row.at('time').attributes['datetime'].value
  text = row.at('a').text
  status << {time: time, text: text} 
end

puts status.to_json
