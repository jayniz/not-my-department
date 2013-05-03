debugger

window.janun = ->
  ace_editor = ace.edit("editor")
  ace_editor.setTheme("ace/theme/monokai")
  ace_editor.getSession().setMode("ace/mode/coffee")

  # Save button
  document.getElementById('save').addEventListener 'click', ->
    config = ace_editor.getValue()
    chrome.storage.local.set(services_string: config)
    chrome.runtime.sendMesage(
      action: 'storeServices'
      services: config
    )

document.addEventListener 'DOMContentLoaded', janun

