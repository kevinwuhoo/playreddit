require 'sinatra'
require 'sass'
require 'nokogiri'
require 'open-uri'
require 'json'

get '/' do
  
  @music = {}
  params.keys[0].split(',').each do |subreddit|
    
    @scrape_reddit = Nokogiri::HTML(open("http://www.reddit.com/r/#{subreddit}"))
    @links = @scrape_reddit.xpath('//a[@class="title "]')
    @links.each do |l|
      if l['href'].include? 'youtube.com/watch?v='
        puts l['href']
        yt_id = l['href'].match(/v=.{11}/)[0][2, l['href'].length]
        @music[l.content] = [yt_id, true]
      elsif l['href'].include? 'soundcloud'
        @music[l.content] = [l['href'], false]
      end
    end
  end
  
  puts @music
  
  erb :play_reddit
end

get '/stylesheet.css' do
  scss :stylesheet
end