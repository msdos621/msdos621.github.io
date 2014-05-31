---
layout: post
author: Jeffery Yeary
title: ! '.Net wrapper for PagerDuty API '
date: '2013-07-13T17:12:14-04:00'
tags: []
tumblr_url: http://psychicdebugging.tumblr.com/post/55367079104/net-wrapper-for-pagerduty-api
---
.Net wrapper for PagerDuty API I have just published my first pass at a .net wrapper for talking to the pager duty api.  The source is on github and the package is up on nuget.org.  Here is a quick example of usage:

{% highlight csharp %}
{% raw %} 
var svc = new PagerDutyAPI("yourpagerdutysubdomain","APIToken");

//Get all the alerts for the last 24 hours
var alerts = svc.GetAlerts(DateTime.Now.AddDays(-1),DateTime.Now,Filter.Unspecified);
{% endraw %}
{% endhighlight %}

