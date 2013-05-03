chrome.storage.onChanged.addListener (changes) ->
  return unless changes.services
  chrome.runtime.sendMessage(
    action: 'services'
    text: changes.services
  )

# Send resolve message off to config window
handler = (e, service) ->
  for text in e.selectionText.split(" ")
    chrome.runtime.sendMessage(
      action: 'resolve'
      service: e.menuItemId
      text:    text
    )

# Receive resolved url from config window and open it
chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  return unless request.action == 'openUrl'
  url = request.url
  chrome.tabs.create(url: url, active: false) if url != ""

chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  return unless request.action == 'init_services'
  parent = chrome.contextMenus.create( contexts: ['selection'], title: "Open as", id: "oaparent" )
  for label in request.services
    chrome.contextMenus.create(
      contexts: ['selection']
      title:    label
      id:       label
      onclick:  handler
      parentId: 'oaparent'
    )


# Create context menus and init sandboxed resolver
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


