
document.addEventListener 'DOMContentLoaded', ->
  # Init with default services
  # chrome.storage.local.get 'services', (val) ->
  #   return if val.services and val.services != ""
  #   debugger
  #   chrome.runtime.sendMessage(
  #     action: 'services'
  #     text: default_services
  #   )

  # Prepare sandboxed iframe
  iFrame = document.getElementById('theFrame')
  iFrame.onload = window.init

  # Receive resolved URL from sandbox window and pass
  # it on to the context menu
  window.addEventListener 'message', (event) ->
    chrome.runtime.sendMessage(event.data)

  # Receive URL to resolve from context menu and pass
  # it on to the sandbox
  chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
    iFrame.contentWindow.postMessage(request, '*')

