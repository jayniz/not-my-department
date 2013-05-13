# Resolvers were changed, let's save them
chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  return unless request.action == "saveServices"
  chrome.storage.local.set(services: request.services)
  window.init()

# Keep the defaults
chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  return unless request.action == "defaultServices"
  chrome.storage.local.set(defaultServices: request.services)


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
  if request.action == 'initServices'
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
  if request.action == 'syntaxError'
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
    if services
      chrome.runtime.sendMessage(
        action: 'services'
        text: services
      )
    else
      chrome.runtime.sendMessage(action: 'getDefaultServices')

