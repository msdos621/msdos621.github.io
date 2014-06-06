require 'forwardable'
require 'ostruct'
require 'net/http'
require 'json'
require 'pry'
module Jekyll

  class FeedPage < Page
    def initialize(site, base, dir, feed_items)
      @site = site
      @base = base
      @dir = dir
      @name = 'latest.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'feed.html')
      self.data['feed_items'] = feed_items
      self.data['title'] = 'Latest Feed Items'
    end
  end

  class FeedPageGenerator < Generator
    def generate(site)
      l = LastFMFeed.new(:username => 'usbsnowcrash', :apikey => '').feed
      i = InstagramFeed.new(:username => '54558149', :apikey => '').feed
      #all_items = i.zip(l).flatten.compact

      all_items = i.concat(l).sort!{ |a,b| a.published <=> b.published }.reverse
      dir = site.config['feed_dir'] || 'feed'
      site.pages << FeedPage.new(site, site.source, dir,all_items)
    end
  end

  class FeedItem
    extend Forwardable
    attr_accessor :source_name, :published, :title, :snippet, :image_preview_uri, :weight

    def initialize(options = {})
      @options = OpenStruct.new(options)
      self.class.instance_eval do
        def_delegators :@options, *options.keys
      end
    end

    def to_liquid
      {
        'source_name'    =>    source_name,
        'published' =>          published,
        'title'       =>     title,
        'snippet'     =>       snippet,
        'image_preview_uri' => image_preview_uri,
        'weight'       =>     weight
      }
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
        publish_date = DateTime.now.to_time
        publish_date = DateTime.parse(track['date']['#text']).to_time if track['date']
        item = FeedItem.new(:source_name        => 'Last FM',
                            :title              => "Played: #{track['artist']['#text']} - #{track['name']}",
                            :snippet            =>  "from the album #{track['album']['#text']}",
                            :image_preview_uri  => track['image'][1]['#text'],
                            :published          => publish_date)

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
        caption = ''
        caption = image['caption']['text'] if image['caption']
        item = FeedItem.new(:source_name          => 'Instagram',
                            :title                => "Took a photo",
                            :snippet              => caption,
                            :image_preview_uri    => image['images']['thumbnail']['url'],
                            :published            => Time.at(image['created_time'].to_i))

        parsed_images.push item
      end
      parsed_images
    end
  end

end