document.addEventListener 'DOMContentLoaded', ->

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

  # Collect some statistics to know if people get how to use this
  chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
    track_event = (event, label = "something", value = "") ->
      _gaq.push(['_trackEvent', event, label, value ])
    switch request.action
      when 'init_services' then track_event('Created configuration', 'items', "#{request.services.length}")
      when 'syntax_error'  then track_event('Config error', 'message', request.message)
      when 'openUrl'       then track_event('Item resolved')

