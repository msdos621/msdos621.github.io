---
layout: post
author: Jeffery Yeary
title: Setting up my ruby envrionment (Ubuntu 13.10)
date: '2013-11-17T00:39:00-05:00'
tags:
- programming
- ruby
- code
tumblr_url: http://psychicdebugging.tumblr.com/post/67229039192/setting-up-my-ruby-envrionment-ubuntu-13-10
---
My machine at home is a monster.  It has dual SSDs in a raid 0 config and a ton of ram.  It is basically a dream to code on.  I recently switched over to ubuntu since most of my development is shifting to ruby and I use a mac to develop at work.  My current stack is rbenv, phantomjs, nodejs, redis (for the session store / other stuff). I was surprised to find that it was actually easier to setup in linux than it was on my mac.Here are the steps I took for Ubuntu 13.10

######First install RBEnv
{% highlight bash %}
git clone git://github.com/sstephenson/rbenv.git .rbenv
echo ''export PATH="$HOME/.rbenv/bin:$PATH"'' >> ~/.bashrc
echo ''eval "$(rbenv init -)"'' >> ~/.bashrc
{% endhighlight %}

######Install ruby build
{% highlight bash %}
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo ''export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"'' >> ~/.bashrc
{% endhighlight %}

######Install your chosen version of Ruby
{% highlight bash %}
rbenv install 1.9.3p448
rbenv global 1.9.3p448
ruby -v
{% endhighlight %}

######Install some rails prereqs (nodejs for the asset pipeline)Since Ubuntu 13.04 has an old version of Node we are going to grab one from Chris Lea’s repo
{% highlight bash %}
sudo add-apt-repository ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get install nodejs
{% endhighlight %}

######Install your chosen version of Rails
{% highlight bash %}
gem install rails
rbenv rehash
rails -v
{% endhighlight %}

######Install redis (for your session store)
{% highlight bash %}
sudo apt-get install tcl
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
make
cd src
sudo cp redis-server /usr/local/bin/
sudo cp redis-cli /usr/local/bin/
cd
rm -rf redis-stable
rm redis-stable.tar.gz
{% endhighlight %}

######Install phantomjs (to help test javascript)
{% highlight bash %}
cd /usr/local/share/
sudo wget http://phantomjs.googlecode.com/files/phantomjs-1.8.1-linux-x86_64.tar.bz2
sudo tar jxvf phantomjs-1.8.1-linux-x86_64.tar.bz2
sudo ln -s /usr/local/share/phantomjs-1.8.1-linux-x86_64/ /usr/local/share/phantomjs
sudo ln -s /usr/local/share/phantomjs/bin/phantomjs /usr/local/bin/phantomjs
sudo rm phantomjs-1.8.1-linux-x86_64.tar.bz2
{% endhighlight %}

Congrats you are now ready to code some stuff.
These commands were lovingly sourced from a lot of different places
- Go Rails setup guide
- Redis quick start guide
- Phantom JS (codecuriosity.com)
