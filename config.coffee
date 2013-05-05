defaults = """
fbLucky = (term, type, tabOpenCallback) ->
  searchUrl = 'https://graph.facebook.com/search?q=moviepilot.com&type=\#{type}'
  $.getJSON(searchUrl).done (r) ->
    tabOpenCallback("http://graph.facebook.com/\#{r.data[0].id}")

{
  "facebook object": (id) -> "https://graph.facebook.com/\#{id}"
  "feeling facebook page lucky":  (term, callback) -> fbLucky(term, 'page', callback)
  "feeling facebook movie lucky": (term, callback) -> fbLucky(term, 'movie', callback)
}
"""

window.janun = ->
  ace_editor = ace.edit("editor")
  ace_editor.setTheme("ace/theme/monokai")
  ace_editor.getSession().setMode("ace/mode/coffee")
  ace_editor.getSession().setTabSize(2)
  ace_editor.getSession().setUseSoftTabs(true)
  chrome.storage.local.get 'services', (s) ->
    ace_editor.setValue(s.services)

  # Save button
  document.getElementById('save-button').addEventListener 'click', ->
    config = ace_editor.getValue()
    chrome.storage.local.set(services: config)
    window.close()

  # Defaults button
  document.getElementById('default-button').addEventListener 'click', ->
    ace_editor.setValue(defaults)

  # Cancel button
  document.getElementById('cancel-button').addEventListener 'click', ->
    window.close()


document.addEventListener 'DOMContentLoaded', janun

