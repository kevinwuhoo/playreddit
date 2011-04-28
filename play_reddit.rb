require 'sinatra'
require 'sass'
require 'Nokogiri'
require 'open-uri'
require 'json'

get '/' do

  @scrape_reddit = Nokogiri::HTML(open('http://www.reddit.com/r/electronicmusic'))
  @links = @scrape_reddit.xpath('//a[@class="title "]')
  @music = {}
  @links.each do |l|
    if l['href'].include? 'youtube'
      yt_id = l['href'].match(/v=.{11}/)[0][2, l['href'].length]
      @music[l.content] = [yt_id, true]
    elsif l['href'].include? 'soundcloud'
      @music[l.content] = [l['href'], false]
    end
  end

  puts @music
  erb :play_reddit
end

get '/stylesheet.css' do
  scss :stylesheet
end