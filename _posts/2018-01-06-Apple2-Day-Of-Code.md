---
layout: post
title:  100 Days of Code
image: /assets/article_images/2gs2.jpg
date:   2018-01-06 14:00:00
tags:
- code
- javascript
- apple2
- 100DaysOfCode
---

I recently left my job at CareerBuilder and I wanted to make sure I stay in peak interviewing shape.  To that end I have decided to join the [100 days of code](https://medium.freecodecamp.org/join-the-100daysofcode-556ddb4579e4) challenge.

#### First project
Monday I dusted off my childhood computer and I have been having a blast playing with it.  The apple 2gs is really a missed opportunity for apple and it would have been amazing to see the continuation of this line.  After hanging around the [Apple II gs enthusiast Facebook group](https://www.facebook.com/groups/AppleIIGSEnthusiasts/) I realized there was a need for a [serial number decoding tool](/tools/apple2_serial/).  There is a great native Mac OS app for doing this but nothing for windows / mobile / other platforms. 

#### How the serial numbers work
You can discern quite a bit form the serial numbers found on old apple computers.  For example, given my serial number *E9378TTA0012LL/A* you can read it like this:
E-9-37-8TT-Model Number
* E - Factory code (E=Singapore, NE=Singapore, CK=Cork Ireland, C=Cork?)
* 9 - Year of production (7=1987, 8=1988, 9=1989, 0=1990, 1=1991...)
* 37 - Week of production
* 8TT - Unit number produced Base 34 number representing what the unit number is.


#### The actual code
Here is the lookup table I used to convert the base 34 number
{% highlight javascript %}
{% raw %} 
DebugNinja.lookupTable = {};
DebugNinja.lookupTable['0'] =	0;
DebugNinja.lookupTable['1'] =	1;
DebugNinja.lookupTable['2'] =	2;
DebugNinja.lookupTable['3'] =	3;
DebugNinja.lookupTable['4'] =	4;
DebugNinja.lookupTable['5'] =	5;
DebugNinja.lookupTable['6'] =	6;
DebugNinja.lookupTable['7'] =	7;
DebugNinja.lookupTable['8'] =	8;
DebugNinja.lookupTable['9'] =	9;
DebugNinja.lookupTable['A'] =	10;
DebugNinja.lookupTable['B'] =	11;
DebugNinja.lookupTable['C'] =	12;
DebugNinja.lookupTable['D'] =	13;
DebugNinja.lookupTable['E'] =	14;
DebugNinja.lookupTable['F'] =	15;
DebugNinja.lookupTable['G'] =	16;
DebugNinja.lookupTable['H'] =	17;
DebugNinja.lookupTable['I'] =	1;
DebugNinja.lookupTable['J'] =	18;
DebugNinja.lookupTable['K'] =	19;
DebugNinja.lookupTable['L'] =	20;
DebugNinja.lookupTable['M'] =	21;
DebugNinja.lookupTable['N'] =	22;
DebugNinja.lookupTable['O'] =	0;
DebugNinja.lookupTable['P'] =	23;
DebugNinja.lookupTable['Q'] =	24;
DebugNinja.lookupTable['R'] =	25;
DebugNinja.lookupTable['S'] =	26;
DebugNinja.lookupTable['T'] =	27;
DebugNinja.lookupTable['U'] =	28;
DebugNinja.lookupTable['V'] =	29;
DebugNinja.lookupTable['W'] =	30;
DebugNinja.lookupTable['X'] =	31;
DebugNinja.lookupTable['Y'] =	32;
DebugNinja.lookupTable['Z'] =	33;
{% endraw %}
{% endhighlight %}

Here is the bulk of the code
{% highlight javascript %}
{% raw %} 
var DebugNinja = DebugNinja || {};
DebugNinja.Apple2GS = function(input) {
  // defaults
  this.serial = input;
  this.factoryCode =  '';
  this.yearOfProduction = -1;
  this.weekOfProduction = -1;
  this.unit = -1;
  
  // find factory
  if (input.startsWith('E')){
    this.factoryCode = 'Singapore';
    input = input.slice(1);
  } else if (input.startsWith('CK')){
    this.factoryCode = 'Cork Ireland';
    input = input.slice(2);
  } else if (input.startsWith('NE')){
    this.factoryCode = 'Singapore?';
    input = input.slice(2);
  } else if (input.startsWith('C')){
    this.factoryCode = 'Cork?';
    input = input.slice(1);
  } else {
    alert('Your Factory code looks off');
    return;
  }
  if (parseInt(input.charAt(0)) >= 7) {
    this.yearOfProduction = 1980 + parseInt(input.charAt(0));
  } else if (parseInt(input.charAt(0)) >= 0) {
    this.yearOfProduction = 1990 + parseInt(input.charAt(0));
  } else {
    alert('Your year of production looks off');
    return;
  }
  input = input.slice(1);
  if (parseInt(input.substring(0,2)) > 0 && parseInt(input.substring(0,2)) <= 52) {
    this.weekOfProduction = parseInt(input.substring(0,2));
  } else {
    alert('Your week of production looks off');
    return;
  }
  input = input.slice(2);
  if(input.length >= 3){
    this.unit = DebugNinja.lookupTable[input.charAt(0)]*(34*34) + DebugNinja.lookupTable[input.charAt(1)]*(34) + DebugNinja.lookupTable[input.charAt(2)]*(1); 
  } else {
    alert('Your unit number looks whack');
  }
}
{% endraw %}
{% endhighlight %}

You can try the [decoding tool here](/tools/apple2_serial/).
