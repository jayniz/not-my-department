# Display messages when user tries to call alert
# in the sandbox (which isn't defined there)
chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  return unless request.action == 'alert'
  webkitNotifications.createNotification(
    'icon/48.png'
    request.title
    request.message
  ).show()

# Collect some statistics to know if people understand how to use this
chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  track_event = (event, label = "something", value = "") ->
    _gaq.push(['_trackEvent', event, label, value ])
  switch request.action
    when 'init_services' then track_event('Created configuration', 'items', "#{request.services.length}")
    when 'syntax_error'  then track_event('Config error', 'message', request.message)
    when 'openUrl'       then track_event('Item resolved')
