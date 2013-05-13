# Display messages when user tries to call alert
# in the sandbox (which isn't defined there)
chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  return unless request.action == 'alert'
  webkitNotifications.createNotification(
    'icon/48.png'
    request.message
    request.title
  ).show()

# Collect some statistics to know if people understand how to use this
chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  trackEvent = (event, label = "something", value = "") ->
    _gaq.push(['_trackEvent', event, label, value ])
  switch request.action
    when 'initServices' then trackEvent('Created configuration', 'items', "#{request.services.length}")
    when 'syntaxError'  then trackEvent('Config error', 'message', request.message)
    when 'openUrl'       then trackEvent('Item resolved')
    when 'defaultsError' then trackEvent('Defaults error')
