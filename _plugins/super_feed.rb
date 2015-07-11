require 'forwardable'
require 'ostruct'
require 'net/http'
require 'json'
require 'pry'
require 'rb-readline'
require 'dotenv'

module Jekyll
  class FeedGenerator < Generator
    def generate(site)
      Dotenv.load

      filter = (Date.today - site.config['superfeed_days_back']).to_time
      b = BlogPostsFeed.new(site.baseurl, site.posts, site.config['blog_feed_limit']).feed
      l = LastFMFeed.new(:username => site.config['last_fm_username'], :apikey => ENV['LASTFM_KEY'], :limit => site.config['last_fm_limit']).feed
      i = InstagramFeed.new(:username => site.config['instagram_username'], :userid => site.config['instagram_id'], :apikey => ENV['INSTAGRAM_KEY'], :limit => site.config['instagram_limit']).feed
      g = GithubFeed.new(:username => site.config['github_username'], :limit => site.config['github_limit']).feed

      all_items = b+ l + i + g
      all_items = all_items.compact.sort!{ |a,b| a.published <=> b.published }.reverse
      site.pages.each do |page|
        page.data['feed_items'] = all_items.select{|item| item.published > filter }
      end
    end
  end



  class FeedItem
    extend Forwardable
    attr_accessor :icon, :source_name, :published, :title, :title_link, :snippet, :image_preview_uri, :profile_link

    def initialize(options = {})
      @options = OpenStruct.new(options)
      self.class.instance_eval do
        def_delegators :@options, *options.keys
      end
    end

    def to_liquid
      {
        'icon'              =>  icon,
        'source_name'       =>  source_name,
        'published'         =>  published,
        'title'             =>  title,
        'title_link'        =>  title_link,
        'snippet'           =>  snippet,
        'image_preview_uri' =>  image_preview_uri,
        'profile_link'      =>  profile_link
      }
    end
  end

  class LastFMFeed
    extend Forwardable
    attr_accessor :username, :apikey, :limit

    def initialize(options = {})
      @options = OpenStruct.new(options)
      self.class.instance_eval do
        def_delegators :@options, *options.keys
      end
    end

    def feed
      puts 'fetching Last fm feed'
      url = "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=#{username}&api_key=#{apikey}&format=json&limit=#{limit}"
      resp = Net::HTTP.get_response(URI.parse(url)) # get_response takes an URI object
      data = JSON.parse(resp.body)
      tracks = data['recenttracks']['track']
      parsed_tracks = []
      tracks.each do |track|
        publish_date = DateTime.now.to_time
        snippet = ''
        snippet = "from the album #{track['album']['#text']}" unless track['album']['#text'].empty?
        publish_date = DateTime.parse(track['date']['#text']).to_time if track['date']
        item = FeedItem.new(:icon               => '/assets/images/social/lastfm.png',
                            :source_name        => 'Last FM',
                            :title              => "Listened to #{track['artist']['#text']} - #{track['name']}",
                            :title_link         => track['url'],
                            :snippet            => snippet,
                            :image_preview_uri  => track['image'][2]['#text'],
                            :published          => publish_date,
                            :profile_link       => "http://www.last.fm/user/#{username}")
        parsed_tracks.push item
      end
      parsed_tracks
    end
  end

  class GithubFeed
    extend Forwardable
    attr_accessor :username, :limit

    def initialize(options = {})
      @options = OpenStruct.new(options)
      self.class.instance_eval do
        def_delegators :@options, *options.keys
      end
    end

    def feed
      puts 'fetching github feed'
      url = "https://api.github.com/users/#{username}/events"
      uri = URI.parse(url)
      response = nil
      Net::HTTP.start(uri.host, uri.port,
                      :use_ssl => true) do |http|
        request = Net::HTTP::Get.new url
        response = http.request request
      end
      gits = JSON.parse(response.body)
      parsed_git = []
      gits.each do |git|
        item = FeedItem.new(:icon                 => '/assets/images/social/github2.png',
                            :source_name          => 'Github',
                            :title                => "#{git['actor']['login']} #{convert_type(git)}",
                            :title_link           => git['repo']['url'],
                            :snippet              => "#{git['repo']['name']}",
                            :image_preview_uri    => "#{git['actor']['avatar_url']}?v=3&s=100" ,
                            :published            => DateTime.parse(git['created_at']).to_time,
                            :profile_link         => "https://github.com/#{username}")
        #binding.pry unless item.snippet.include?('triggered from publish script')
        parsed_git.push item unless git['repo']['name'].include?('usbsnowcrash.github.io')
      end
      parsed_git.sort { |a,b| a.published <=> b.published }.last(limit)
    end

    def convert_type(git)
      return delete_snippit(git) if git['type'] == 'DeleteEvent'
      return push_snippit(git) if git['type'] == 'PushEvent'
      return pull_snippit(git) if git['type'] == 'PullRequestEvent'
      return create_snippit(git) if git['type'] == 'CreateEvent'
      return delete_snippit(git) if git['type'] == 'DeleteEvent'
      git['type'].gsub('MemberEvent','added a member to')
    end

    def delete_snippit(git)
      "deleted a #{git['payload']['ref_type']} (#{git['payload']['ref']})"
    end

    def push_snippit(git)
      "pushed to #{git['payload']['ref']}"
    end

    def pull_snippit(git)
      "#{git['payload']['action']} \##{git['payload']['number']} - #{git['payload']['pull_request']['title']}"
    end

    def create_snippit(git)
      "created a #{git['payload']['ref_type']} (#{git['payload']['ref']})"
    end

    def member_snippit(git)
      "created a #{git['payload']['ref_type']} (#{git['payload']['ref']})"
    end
  end

  class InstagramFeed
    extend Forwardable
    attr_accessor :username,:userid, :apikey, :limit

    def initialize(options = {})
      @options = OpenStruct.new(options)
      self.class.instance_eval do
        def_delegators :@options, *options.keys
      end
    end

    def feed
      puts 'fetching instagram feed'
      #url = "https://api.instagram.com/v1/users/#{userid}/media/recent/?access_token=#{apikey}&count=#{limit}"
      #uri = URI.parse(url)
      #response = nil
      #Net::HTTP.start(uri.host, uri.port,
      #                :use_ssl => true) do |http|
      #  request = Net::HTTP::Get.new url
      #  response = http.request request
      #end
      #data = JSON.parse(response.body)
      #
      #images = data['data']
      parsed_images = []
      #images.each do |image|
      #  caption = ''
      #  caption = image['caption']['text'] if image['caption']
      #  item = FeedItem.new(:icon                 => '/assets/images/social/instagram.png',
      #                      :source_name          => 'Instagram',
      #                      :title                => 'Took a photo',
      #                      :title_link           => image['link'],
      #                      :snippet              => caption,
      #                      :image_preview_uri    => image['images']['thumbnail']['url'],
      #                      :published            => Time.at(image['created_time'].to_i),
      #                      :profile_link         => "http://instagram.com/#{username}")
      #  parsed_images.push item
      #end
      parsed_images.sort { |a,b| a.published <=> b.published }.last(limit)
    end
  end

  class BlogPostsFeed
    attr_accessor :base_url, :posts, :limit

    def initialize(base_url, posts, limit)
      @posts = posts
      @base_url = base_url
      @limit = limit
    end

    def feed
      puts 'fetching blog posts feed'
      feed_items = []
      recent_posts = @posts.last limit
      recent_posts.each do |post|
        item = FeedItem.new(:icon                 => '/assets/images/social/rss.png',
                            :source_name          => 'BlogPosts',
                            :title                => post.title,
                            :title_link           => post.url.prepend(base_url),
                            :snippet              => post.excerpt,
                            :image_preview_uri    => nil,
                            :published            => post.date)

        feed_items.push item
      end
      feed_items.sort { |a,b| a.published <=> b.published }.last(limit)
    end
  end

end