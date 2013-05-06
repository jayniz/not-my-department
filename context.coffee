# Resolvers were changed, let's save them
chrome.storage.onChanged.addListener (changes) ->
  return unless changes.services
  chrome.runtime.sendMessage(
    action: 'services'
    text: changes.services
  )
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
  return unless request.action == 'init_services'
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

# Send configuration json to sandbox so it can eval it
# and tell us which context menu items to create
window.init = ->
  default_services = """
services = {
  "facebook object": (id) -> "https://graph.facebook.com/\#{id}"
}
  """
  services = chrome.storage.local.get 'services', (val) ->
    services = val.services or default_services
    chrome.runtime.sendMessage(
      action: 'services'
      text: services
    )


