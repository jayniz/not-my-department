document.addEventListener 'DOMContentLoaded', ->

  iFrame = document.getElementById('theFrame')
  iFrame.onload = window.init_services

  # Receive resolved URL from sandbox window and pass
  # it on to the context menu
  window.addEventListener 'message', (event) ->
    chrome.runtime.sendMessage(event.data)

  # Receive URL to resolve from context menu and pass
  # it on to the sandbox
  chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
    iFrame.contentWindow.postMessage(request, '*')

