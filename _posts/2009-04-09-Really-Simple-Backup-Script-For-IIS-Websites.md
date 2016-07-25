---
layout: post
title:  Really simple backup script for IIS websites
date:   2009-04-07 17:18:00
tags:
- devops
- script
- windows
---

The file based nature of Blog Engine .Net makes me a little nervous.  I decided to whip up a little script to take nightly snapshots of my web application folder.  The goal was to create a directory with the date in it and to copy the contents of my iis folder on a schedule.  This is really just a fancy wrapper for [xcopy](http://technet.microsoft.com/en-us/library/bb491035.aspx) but I thought I would post it anyway.


{% highlight sh %}
{% raw %}
@ECHO OFF
set BkupDir="C:\Backups"
set SrcDir="D:\websites"
set Year=%date:~10,4%
set Month=%date:~4,2%
set Day=%date:~7,2%
c:
@ECHO Creating backup directory
mkdir %BkupDir%\%Year%-%Month%-%Day%
d:
cd %SrcDir%
ECHO Begining XCopy
xcopy %SrcDir%\*.* %BkupDir%\%Year%-%Month%-%Day%\ /S /E /V /C /H /R /K /O /Y > %BkupDir%\%Year%-%Month%-%Day%\bkup.log
{% endraw %}
{% endhighlight %}
