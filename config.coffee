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

window.undBitte = ->
  ace_editor = ace.edit("editor")
  ace_editor.setTheme("ace/theme/monokai")
  ace_editor.getSession().setMode("ace/mode/coffee")
  ace_editor.getSession().setTabSize(2)
  ace_editor.getSession().setUseSoftTabs(true)
  chrome.storage.local.get 'services', (s) ->
    if services = s.services
      ace_editor.setValue(s.services)
    else
      ace_editor.setValue("# Try the defaults button, then hit save")
    ace_editor.selection.clearSelection()

  # Save button
  document.getElementById('save-button').addEventListener 'click', ->
    config = ace_editor.getValue()
    chrome.runtime.sendMessage(
      action: 'save_services'
      services: config
    )
    # window.close()

  # Help button
  document.getElementById('help-button').addEventListener 'click', ->
    url = 'https://github.com/jayniz/open-as#readme'
    chrome.tabs.create(url: url, active: true) if url != ""
    window.close()

  # Defaults button
  document.getElementById('default-button').addEventListener 'click', ->
    ace_editor.setValue(default_services)
    ace_editor.selection.clearSelection()

  # close button
  document.getElementById('close-button').addEventListener 'click', ->
    window.close()

  # Status
  chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
    debugger
    sl = document.getElementById('status-label')
    return unless request.action == "init_services" or request.action == "syntax_error"
    if request.action == "init_services"
      sl.innerText = "Saved, #{request.services.length} menu items created"
      window.setTimeout((-> sl.innerText = ''), 2000)
    if request.action == "syntax_error"
      sl.innerText = request.message

document.addEventListener 'DOMContentLoaded', undBitte

