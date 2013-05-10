default_services = """
# Since this is CoffeeScript, you can do anything you want here,
# you have jquery and underscore to do your stuff. For example,
# make a search and open the first result:
myOwnResolver = (selectedText, callback) ->
  url = "http://graph.facebook.com/search?q=\#{selectedText}&type=person"
  r = $.getJSON(url)
  r.done (d) ->
    callback("http://graph.facebook.com/\#{d.data[0].id}")

{
  "Facebook object": (id) -> "https://graph.facebook.com/\#{id}"
  "My own menu item": myOwnResolver
}
"""

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
    services = val.services or default_services
    chrome.runtime.sendMessage(
      action: 'services'
      text: services
    )


