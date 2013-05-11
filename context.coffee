default_services = """
# You have jquery and underscore available. Hack away!
# Don't try console.log, it will not work because this stuff
# is run in a sandbox. But you can use alert.

# An example for a more elaborated resolver than just putting
# a word in a string: Resolve a unix timestamp
timestamp = (val) ->
  date = new Date(val)
  alert(date.toLocaleString())

# This has to be the last part of your script, and it defines
# the context menu items that will be created.
{
  "Timestamp": timestamp
  "Facebook object": (id) -> "https://facebook.com/\#{id}"
  "Subreddit":     (word) -> "http://reddit.com/r/\#{word}"
  "Twitter user":  (user) -> "http://twitter.com/\#{user}"
}
"""

chrome.storage.local.get 'services', (val) ->
  return if val.services
  chrome.storage.local.set(services: default_services)

# Resolvers were changed, let's save them
chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  return unless request.action == "save_services"
  chrome.storage.local.set(services: request.services)
  window.init()

# Send resolve message off to config window
handler = (e, service) ->
  chrome.runtime.sendMessage(
    action: 'resolve'
    service: e.menuItemId
    text:    e.selectionText
  )

# Receive resolved url from config window and open it
chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  return unless request.action == 'openUrl'
  url = request.url
  chrome.tabs.create(url: url, active: false) if url != ""

# Sandboxed window told us which services exist,
# create the context menu items
chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  if request.action == 'init_services'
    chrome.contextMenus.removeAll ->
      parent = chrome.contextMenus.create( contexts: ['selection'], title: "Open as...", id: "oaparent" )
      for label in request.services
        chrome.contextMenus.create(
          contexts: ['selection']
          title:    label
          id:       label
          onclick:  handler
          parentId: 'oaparent'
        )
  if request.action == 'syntax_error'
    chrome.contextMenus.removeAll ->
      parent = chrome.contextMenus.create( contexts: ['selection'], title: "Open as...", id: "oaparent" )
      for label in ['Parse', 'Error', 'Check', 'Your', 'Config', ':)']
        chrome.contextMenus.create(
          contexts: ['selection']
          title:    label
          id:       label
          onclick:  handler
          parentId: 'oaparent'
        )


# Send configuration json to sandbox so it can eval it
# and tell us which context menu items to create
window.init = ->
  chrome.storage.local.get 'services', (val) ->
    services = val.services
    chrome.runtime.sendMessage(
      action: 'services'
      text: services
    )


