default_services = """
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
  "Facebook object": (id) -> "https://facebook.com/\#{id}"
  "Subreddit":     (word) -> "http://reddit.com/r/\#{word}"
  "Twitter user":  (user) -> "http://twitter.com/\#{user}"
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
      ace_editor.setValue("# Try the example button, then hit save")
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
      sl.innerText = "Alrighty, #{request.services.length} menu items created"
      window.setTimeout((-> sl.innerText = ''), 2000)
    if request.action == "syntax_error"
      sl.innerText = request.message

document.addEventListener 'DOMContentLoaded', undBitte

