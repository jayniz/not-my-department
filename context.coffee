services = {
  "facebook object": (id) -> "https://graph.facebook.com/#{id}"
  "sheldon node"   : (id) -> "http://primus.sheldon.moviepilot.com/nodes/#{id}"
  "mp.de movie"    : (id) -> "http://moviepilot.de/movies/#{id}"
  "mp.com movie"   : (id) -> "http://moviepilot.com/movies/#{id}"
}

handler = (e, service) ->
  fn = services[e.menuItemId]
  chrome.tabs.create(url: fn(e.selectionText))

parent = chrome.contextMenus.create( contexts: ['selection'], title: "Open as", id: "oaparent" )
for label,resolver of services
  chrome.contextMenus.create(
    contexts: ['selection']
    title:    label
    id:       label
    onclick:  handler
    parentId: 'oaparent'
  )
