services = {
  "facebook object": (id) -> "https://graph.facebook.com/#{id}"
  "sheldon node"   : (id) -> "http://primus.sheldon.moviepilot.com/nodes/#{id}"
  "mp.de movie"    : (id) -> "http://www.moviepilot.de/movies/#{id}"
  "mp.com movie"   : (id) -> "http://moviepilot.com/movies/#{id}"
}

chrome.storage.onChanged.addListener (changes) ->
  return unless changes.services
  parsed = CoffeeScript.compile(changes.services, bare: true)
  chrome.storage.local.set(services: changes.services)
  services = parsed

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

parent = chrome.contextMenus.create( contexts: ['selection'], title: "Open as", id: "oaparent" )
for label,resolver of services
  chrome.contextMenus.create(
    contexts: ['selection']
    title:    label
    id:       label
    onclick:  handler
    parentId: 'oaparent'
  )

window.init_services = ->
  chrome.runtime.sendMessage(
    action: 'services'
    text: """
  services = {
    "facebook object": (id) -> "https://graph.facebook.com/\#{id}"
    "sheldon node"   : (id) -> "http://primus.sheldon.moviepilot.com/nodes/\#{id}"
    "mp.de movie"    : (id) -> "http://www.moviepilot.de/movies/\#{id}"
    "mp.com movie"   : (id) -> "http://moviepilot.com/movies/\#{id}"
  }
  """
  )


