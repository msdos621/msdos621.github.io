---
layout: post
title:  Quick and Dirty Last FM Feed parsing in ruby
date:   2014-06-01 17:53:23
image: /assets/article_images/quick_dirty.jpg
tags:
- jekyll
- ruby
- code
---
I am in the process of writing a Jekyll plugin to display information from my social feeds.
Think of it like a life stream or an aggregation of my public internet presence.
Here is an example of my parsing my most recent tracks on last fm.

{% highlight ruby %}

{% raw %}
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
{% endraw %}

{% endhighlight %}

You can follow my progress by watching [this branch here](https://github.com/usbsnowcrash/usbsnowcrash.github.io/tree/superfeed_plugin)
