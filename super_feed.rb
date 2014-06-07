require 'forwardable'
require 'ostruct'
require 'net/http'
require 'json'
require 'pry'

module SuperFeed
  class FeedItem
    extend Forwardable
    attr_accessor :source_name, :published, :title, :snippet, :image_preview_uri, :weight

    def initialize(options = {})
      @options = OpenStruct.new(options)
      self.class.instance_eval do
        def_delegators :@options, *options.keys
      end
    end
  end

  class LastFMFeed
    extend Forwardable
    attr_accessor :username, :apikey

    def initialize(options = {})
      @options = OpenStruct.new(options)
      self.class.instance_eval do
        def_delegators :@options, *options.keys
      end
    end

    def feed
      url = "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=#{username}&api_key=#{apikey}&format=json&limit=200"
      resp = Net::HTTP.get_response(URI.parse(url)) # get_response takes an URI object
      data = JSON.parse(resp.body)
      tracks = data['recenttracks']['track']
      parsed_tracks = []
      tracks.each do |track|
        item = FeedItem.new(:source_name        => 'Last FM',
                            :title              => "Played: #{track['artist']['#text']} - #{track['name']}",
                            :snippet            =>  "from the album #{track['album']['#text']}",
                            :image_preview_uri  => track['image'][1]['#text'])

        item.published = DateTime.now
        item.published = DateTime.parse(track['date']['#text']) if track['date']
        parsed_tracks.push item
      end
      parsed_tracks
    end
  end

  class InstagramFeed
    extend Forwardable
    attr_accessor :username, :apikey

    def initialize(options = {})
      @options = OpenStruct.new(options)
      self.class.instance_eval do
        def_delegators :@options, *options.keys
      end
    end

    def feed
      url = "https://api.instagram.com/v1/users/#{username}/media/recent/?access_token=#{apikey}&count=200"
      puts url
      uri = URI.parse(url)
      response = nil
      Net::HTTP.start(uri.host, uri.port,
                      :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new url
        response = http.request request
      end
      data = JSON.parse(response.body)

      images = data['data']
      parsed_images = []
      images.each do |image|
         item = FeedItem.new(:source_name        => 'Instagram',
                             :title              => "Took a photo",
                             :image_preview_uri  => image['images']['thumbnail']['url'],
                             :published          => Time.at(image['created_time'].to_i))
        item.snippet = image['caption']['text'] if image['caption']
        parsed_images.push item
      end
      binding.pry
      parsed_images
    end
  end


  class FeedAggregator
    def latest_items
      LastFMFeed.new(:username => 'usbsnowcrash', :apikey => '').feed
      InstagramFeed.new(:username => '54558149', :apikey => '').feed
    end
   end
 end



SuperFeed::FeedAggregator.new().latest_items


