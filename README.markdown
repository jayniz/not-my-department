Not my department
=================

This is a chrome extension that adds an 'Open as...' context menu
with configurable actions: search, open on an API, 100% scriptable
via CoffeeScript. I needed something like this while working on
APIs, so I decided to try out how these Chrome extensions work
and write one myself.


How to configure
-----------------

It's just CoffeeScript. You can write your own functions that get
called when you right click on words in chrome. It could be as
easy as just taking the word and opening it as a twitter username.
Or, it could treat the word as an internal ID of one of your
services, look it up, take the result, trigger an action somewhere
else and finally display a message via chrome notifications.


Example configuration
---------------------

```coffee
# You have jquery and underscore available. Hack away!
#
# (Don't try console.log, it will not work because this stuff
# is run in a sandbox. But you can use alert)

# An example for a more elaborated resolver than just putting
# a word in a string:
#   Resolve a unix (seconds) or js (milliseconds) timestamp
timestamp = (val) ->
  in_ms = Math.abs(+new Date()/val) < 100
  val *= 1000 unless in_ms
  date = new Date(val)
  alert(date.toLocaleString())

# This has to be the last part of your script, and it defines
# the context menu items that will be created.
{
  "Timestamp": timestamp
  "Facebook object": (id) -> "https://facebook.com/#{id}"
  "Subreddit":     (word) -> "http://reddit.com/r/#{word}"
  "Twitter user":  (user) -> "http://twitter.com/#{user}"
}
```

More complicated resolver
-------------------------

So let's make a facebook graph search, take the first result, and
open it:

```coffee
feelingFacebookLucky = (selectedText, openTabCallback) ->
  term = encodeURIComponent(selectedText)
  url = "http://graph.facebook.com/search?q=#{term}&type=page"
  r = $.getJSON(url)
  r.done (d) ->
    return alert('Did not find anything') if d.data.length == 0
    openTabCallback("http://graph.facebook.com/#{d.data[0].id}")

{
  "I'm feeling lucky": feelingFacebookLucky
}
```


Acknowledgements
----------------

I used the lovely rubix cube icons from 
[shlyapnikova's](http://shlyapnikova.deviantart.com/art/Rubik-s-Cube-Icon-163909690) deviant art.
