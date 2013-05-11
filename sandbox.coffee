# Little helper, people try to call alert in their
# configuration, but it can't bubble up from the
# sandbox. So we take it and show it as a desktop
# notification
last_event = null
alert = (message, title = 'Alert') ->
  options = {action: 'alert', message: message, title: title}
  event.source.postMessage(options, event.origin)

# Take coffeescript, parse it into javascript,
# eval it and store the service resolver functions
parseServices = (event) ->
  try
    text = event.data.text
    coffee = CoffeeScript.compile(text, {bare: true})
    evaled = eval(coffee)
    if evaled instanceof Object
      window.services = evaled
      services_list = for name, fn of window.services
        name
      event.source.postMessage({action: 'init_services', services: services_list}, event.origin)
    else
      event.source.postMessage({action: 'syntax_error', message: "Error: returned #{typeof evaled} instead of Object"}, event.origin)
  catch e
    event.source.postMessage({action: 'syntax_error', message: e.toString(), exception: JSON.stringify(e)}, event.origin)

# Resolve a keyword into a url
resolve = (event) ->
  last_event = event # We need this for helpers like alert
  fn = window.services[event.data.service]
  text = event.data.text
  post_callback = (url) ->
    event.source.postMessage({action: 'openUrl', url: url }, event.origin)
  url = fn(text, post_callback)
  if typeof url == "string"
    post_callback(url) 

# Respond to requests from the safe, cozy world of extensions,
# where no eval happens.
window.addEventListener 'message', (event) ->
  parseServices(event) if(event.data.action == 'services')
  resolve(event)       if(event.data.action == 'resolve')

