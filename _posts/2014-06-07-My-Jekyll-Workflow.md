---
layout: post
title:  My Jekyll Workflow
author: Jeffery Yeary
date:   2014-06-07 10:45:00
tags:
- jekyll
- bash
- code
---
##### My Blog setup
I use [github pages](https://pages.github.com/) to host my blog.  It is free, its fast and since this is a programming related blog it makes sense.  Also it means, right out of the box, I have source control which I think is neat. I can also publish my blog from any machine with git access (pretty much all my machines).  Another bonus is that every time I work on my blog my github stats are updated which makes me look a lot more active on github.  Finally they support custom domains out of the box so I could purchase this sweet .ninja domain.

##### Frontend setup
I chose to use the [foundation grid system](http://foundation.zurb.com/) because we use it at work ([check it out](http://m.careerbuilder.com)) and it seemed a lot less complicated than twitter bootstrap.  I really like the simplicity of making a page look good on different screen sizes.  All I have to remember is that I should always add up to twelve columns.  On larger screens I have a navigation bar on the right, on tablets the stuff in the right column slides underneath and splits to be side by side.  On phones the panels from the size bar stack on top of each other instead of sitting beside each other.  This is how I set it up:

{% highlight html %}
{% raw %}
    <div class="row">
      <div class="small-12 medium-9 columns" role="content">
        {{ content goes here }}
      </div>
        <!-- Side navigation, on a large screen we float it to the side.  On a phone and tablet we want the entire navigation panel to slide underneath the content -->
        <aside class="small-12 large-3 columns">
          <div class="row">
            <div class="small-12 columns">
              <h5>Posts by Tag</h5>
              <ul class="inline-list">
                {% assign tags_list = site.tags %}  
                {% include taghelper.html %}
                <li><a href="/blog/">All Posts →</a></li>
              </ul>
            </div>
            <!-- On a phone we take the entire width because the whole left column is stacked underneath the content-->
            <div class="small-12 medium-6 large-12 columns">
              <div class="panel text-center">
                <a href="/about/"><img src="/assets/images/selfie.png" alt="Selfie" /></a>
                <h5 class="text-left">Hi I'm Jeff,</h5>
                  <p class="text-left">I am a software architect with a passion for music, coding, fitness and art.  This is my portfolio / blog / space on the internet.</p>
                  <hr />
                  <a href="/about/">See More →</a>
              </div>
            </div>
            <!-- On a tablet we put the two parts of the navigation side by side since we have extra realestate -->
            <div class="small-12 medium-6 large-12 columns">
              <div class="panel">
                <h5>Digital Footprints</h5>
                <hr />
                <ul class="small-block-grid-6 medium-block-grid-3 large-block-grid-3">
                  <li><a href="http://8tracks.com/usbsnowcrash"><img src="/assets/images/social/8tracks.png"></a></li>
                  <li><a href="http://instagram.com/usbsnowcrash"><img src="/assets/images/social/instagram.png"></a></li>
                  <li><a href="http://www.last.fm/user/usbsnowcrash"><img src="/assets/images/social/lastfm.png"></a></li>
                  <li><a href="http://lnkd.in/NWMsmR"><img src="/assets/images/social/linkedin.png"></a></li>
                  <li><a href="http://www.pinterest.com/jefferyyeary/"><img src="/assets/images/social/pinterest.png"></a></li>
                  <li><a href="{{ "/feed.xml" | prepend: site.baseurl }}"><img src="/assets/images/social/rss.png"></a></li>
                  <li><a href="https://twitter.com/usbsnowcrash"><img src="/assets/images/social/twitter.png"></a></li>
                  <li><a href="http://www.youtube.com/user/usbsnowcrash"><img src="/assets/images/social/youtube.png"></a></li>
                </ul>
              </div>
            </div>
          </div>
        </aside>
    </div>
{% endraw %}
{% endhighlight %}

Since this is a coding blog I wanted to make sure that code looked pretty.  Jekyll ships with pretty good [highlighting ability](http://jekyllrb.com/docs/posts/) built on pygments and I was able to theme it by adding the styles found in one of the themes from the [pygments website](http://richleland.github.io/pygments-css/).

I also wanted a nice readable font so I hopped over to [google fonts](https://www.google.com/fonts) and browsed around until I found one I liked.  I chose Lato which is what we use for our mobile site at work so I probobally just like it because it seems familiar.

##### Speeding things up
For speed purposes I wanted my CSS and JS combined and minified and served from one domain.  I could have had this be part of my publishing script but I figured why bother when I can have that done automagically for me.  So I signed up for [cloudflare](http://www.cloudflare.com), which in addition to acting as a free CDN and free DNS provider, will also optimize your CSS and JS for you.  

![Cloudflare Magic](/assets/images/cloudflare_magic.png)

They basically act as a giant reverse proxy between your website and the users that can rewrite your html as well as serve your assets from a server closer to the user.

##### Serving my blog without prepending WWW
So github supports CNAME setups but by default you cannot have the root domain be a CNAME.  So I created an A record that points to the IP address of github.com which I got by pinging the non-friendly url for my github page 

{% highlight bash %}
{% raw %}
Jefferys-iMac:blog jyeary$ ping usbsnowcrash.github.io
PING github.map.fastly.net (199.27.73.133): 56 data bytes
64 bytes from 199.27.73.133: icmp_seq=0 ttl=58 time=30.601 ms
{% endraw %}
{% endhighlight %}

Here is what that setup looks like in the cloudflare control panel.

![DNS Setup](/assets/images/cloudflare-dns.png)

This means if someone types debug.ninja into thier browser bar it resolves to github's servers which understand that they need to serve the contents from my personal github profile.  However I wanted to make sure that if someone did type in www.debug.ninja out of habit it would still work.  So I set that up as a CNAME record of the root domain as shown above.

##### Customizing Jekyll
My blog was originally hosted on tumblr and I really liked the way you tagged posts there.  Jekyll allows you add any meta data you want to your posts so I added tags.  Here is what the top of this post looks like in source control

{% highlight bash %}
{% raw %}
---
layout: post
title:  My Jekyll Workflow
author: Jeffery Yeary
date:   2014-06-07 10:45:00
tags:
- jekyll
- bash
- code
---
{% endraw %}
{% endhighlight %}

I then borrowed some code from the [jekyll bootstrap project](http://jekyllbootstrap.com/) to generate a list of tags on each post as well as a tags page that shows how many posts each individual tag has.  This is what the include file looks like to generate a list of tags:

{% highlight html %}
{% raw %}
{% comment %}<!--
Taken from Jekyll Bootstrap!
The tags_list include is a listing helper for tags.
Usage:
  1) assign the 'tags_list' variable to a valid array of tags.
  2) include taghelper
  example:
    <ul>
      {% assign tags_list = site.tags %}  
      {% include taghelper %}
    </ul>
  
  Notes: 
    Tags can be either a Hash of tag objects (hashes) or an Array of tag-names (strings).
    The encapsulating 'if' statement checks whether tags_list is a Hash or Array.
    site.tags is a Hash while page.tags is an array.
-->{% endcomment %}

  {% if tags_list.first[0] == null %}
    {% for tag in tags_list %} 
      <li><a href="{{ BASE_PATH }}/tags/#{{ tag }}-ref">{{ tag }} <span>({{ site.tags[tag].size }})</span></a></li>
    {% endfor %}
  {% else %}
    {% for tag in tags_list %} 
      <li><a href="{{ BASE_PATH }}/tags/#{{ tag[0] }}-ref">{{ tag[0] }} <span>({{ tag[1].size }})</span></a></li>
    {% endfor %}
  {% endif %}

{% assign tags_list = nil %}
{% endraw %}
{% endhighlight %}

This is an example of how I list the tags in the navigation bar on the right:

{% highlight html %}
{% raw %}
<ul class="inline-list">
{% assign tags_list = site.tags %}  
{% include taghelper.html %}
<li><a href="/blog/">All Posts →</a>
{% endraw %}
{% endhighlight %}

##### Publishing my blog 
Github pages supports jekyll out of the box so you can really easily publish a site by simply pushing up the contents of your jekyll directory.  However, this does not allow you to run any custom plugins due to security concerns on github’s side.  In order to get around this I created two branches for my blog.  The first branch is the [master branch](https://github.com/usbsnowcrash/usbsnowcrash.github.io) and it will contain the generated site.  The second branch is called [blog](https://github.com/usbsnowcrash/usbsnowcrash.github.io/tree/blog) and it contains my jekyll installation that is used to generate the site.  On my machine I have the two branches cloned and in separate directories.  I then wrote this handy publish script which, when run from the blog branch, generates the site and pushes the contents up to github.  This allows me to run any custom plugins I want from my machine since I am doing the content generation.

{% highlight bash %}
{% raw %}
#publish.sh
rm -rf ../usbsnowcrash.github.io/*
jekyll build --destination ../usbsnowcrash.github.io/
cd ../usbsnowcrash.github.io/
git add -u .
git add .
git commit -m "Commit into master triggered from publish script `date`"
git push origin master
cd ../blog
git add .
git commit -m "Commit into blog triggered from publish script `date`"
git push origin blog
{% endraw %}
{% endhighlight %}

So when I want to create a new post I just make the changes on the blog branch and check them in with a helpful comment like so:

{% highlight bash %}
{% raw %}
vim /_posts/2014-01-01-some-new-post.md
git add .
git commit "OMG new post"
git push origin blog
{% endraw %}
{% endhighlight %}

And then when I am ready to publish these changes I run the publish script like so:

{% highlight bash %}
{% raw %}
./publish.sh
{% endraw %}
{% endhighlight %}

If you want to see how anything else works feel free to head over to the [github repo](https://github.com/usbsnowcrash/usbsnowcrash.github.io) and check it out.
