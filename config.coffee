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
      ace_editor.setValue("# Couldn't load the defaults from github, this is an error :( \n#\n# Click the help button below and you will find defaults.\n# Copy there, paste here, adjust to your needs and you're set :)")
    ace_editor.selection.clearSelection()

  # Save button
  document.getElementById('save-button').addEventListener 'click', ->
    config = ace_editor.getValue()
    chrome.runtime.sendMessage(
      action: 'saveServices'
      services: config
    )
    # window.close()

  # Help button
  document.getElementById('help-button').addEventListener 'click', ->
    url = 'https://github.com/jayniz/not-my-department#readme'
    chrome.tabs.create(url: url, active: true) if url != ""
    window.close()

  # Defaults button
  document.getElementById('default-button').addEventListener 'click', ->
    document.getElementById('status-label').innerText = 'Loading defaults from github...'
    chrome.runtime.sendMessage(action: 'getDefaultServices')
  chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
    return unless request.action == "defaultServices"
    document.getElementById('status-label').innerText = ''
    ace_editor.setValue(request.services)
    ace_editor.selection.clearSelection()


  # close button
  document.getElementById('close-button').addEventListener 'click', ->
    window.close()

  # Status
  chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
    sl = document.getElementById('status-label')
    return unless request.action == "initServices" or request.action == "syntaxError"
    if request.action == "initServices"
      sl.innerText = "Alrighty, #{request.services.length} menu items created"
      window.setTimeout((-> sl.innerText = ''), 2000)
    if request.action == "syntaxError"
      sl.innerText = request.message

document.addEventListener 'DOMContentLoaded', undBitte

