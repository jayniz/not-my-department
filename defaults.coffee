# You have jquery and underscore available. Hack away!
# Don't try console.log, it will not work because this stuff
# is run in a sandbox. But you can use alert.

# An example for a more elaborated resolver than just putting
# a word in a string: Resolve a unix timestamp
timestamp = (val) ->
  date = new Date(val*1000)
  alert(date.toLocaleString())

# This has to be the last part of your script, and it defines
# the context menu items that will be created.
{
  "Timestamp": timestamp
  "Facebook object": (id) -> "https://facebook.com/#{id}"
  "Subreddit":     (word) -> "http://reddit.com/r/#{word}"
  "Twitter user":  (user) -> "http://twitter.com/#{user}"
}
