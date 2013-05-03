debugger

window.janun = ->
  ace_editor = ace.edit("editor")
  ace_editor.setTheme("ace/theme/monokai")
  ace_editor.getSession().setMode("ace/mode/coffee")
  chrome.storage.local.get 'services', (s) ->
    ace_editor.setValue(s.services)

  # Save button
  document.getElementById('save').addEventListener 'click', ->
    config = ace_editor.getValue()
    chrome.storage.local.set(services: config)

document.addEventListener 'DOMContentLoaded', janun

