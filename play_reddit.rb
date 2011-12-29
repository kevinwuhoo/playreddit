require 'sinatra'
require 'sass'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'haml'
require 'coffee-script'

# DataMapper::setup(:default, ENV['DATABASE_URL'] || 
#     "sqlite3://#{File.join(File.dirname(__FILE__), 'db', 'play_reddit.db')}")

# class Cache
#   include DataMapper::Resource
  
#   property :id,          Serial
#   property :description, Text, :required => true
#   property :is_done,     Boolean
# end  

# DataMapper.auto_upgrade!

get '/' do
  haml :play_reddit
end

# Scrapes reddit json page
# Returns all scraped relevant info (url, ytid, reddit link) and last reddit id
def extract_links(reddit_page)
  @music = {}
  reddit_page['data']['children'].each do |item|
    data = item['data'] if !item['data'].nil?
    media = data['media'] if !data['media'].nil?
    oembed = media['oembed'] if !media.nil? and !media['oembed'].nil?

    # Youtube
    if !oembed.nil? and data['domain'] == 'youtube.com'
      # @music[oembed['title']] = {url:oembed['url'], reddit:data['permalink']}
      yt_url = oembed['url']
      yt_id = yt_url.match(/v=.{11}/)[0][2, yt_url.length]
      @music[oembed['title']] = {ytid:yt_id, url:yt_url, reddit:data['permalink']}

    # Soundcloud
    elsif !oembed.nil? and data['domain'] == 'soundcloud.com'
      @music[oembed['title']] = {url:data['url'], reddit:data['permalink']}
    end
  end

  last_id = reddit_page['data']['after']
  puts last_id
  return @music, last_id
end

get '/scrape' do

  @music = {}
  reddit_url = "http://reddit.com/r/"
  if params['r']
    params['r'].split(',').each do |subreddit|
      subreddit_url = reddit_url + "#{subreddit}.json"
      reddit_page = JSON(open(reddit_url + "#{subreddit}.json").read())
      scraped_music, last_id = extract_links(reddit_page)      
      # @music = scraped_music

      # Janky scrape second page
      subreddit_url = reddit_url + "#{subreddit}.json?after=#{last_id}"
      reddit_page = JSON(open(subreddit_url).read())
      scraped_music2, last_id = extract_links(reddit_page)      
      # @music = scraped_music

      @music = scraped_music.merge(scraped_music2)

    end
  end

  content_type :json
  @music.to_json
end

get '/playreddit.css' do
  scss :stylesheet
end

get '/playreddit.js' do
  coffee :script
end