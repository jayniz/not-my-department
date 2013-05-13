# Little helper, people try to call alert in their
# configuration, but it can't bubble up from the
# sandbox. So we take it and show it as a desktop
# notification
lastEvent = null
alert = (message, title = 'Alert') ->
  options = {action: 'alert', message: message, title: title}
  lastEvent.source.postMessage(options, lastEvent.origin)

# Take coffeescript, parse it into javascript,
# eval it and store the service resolver functions
parseServices = (event) ->
  try
    text = event.data.text
    coffee = CoffeeScript.compile(text, {bare: true})
    evaled = eval(coffee)
    if evaled instanceof Object
      window.services = evaled
      servicesList = for name, fn of window.services
        name
      event.source.postMessage({action: 'initServices', services: servicesList}, event.origin)
    else
      event.source.postMessage({action: 'syntaxError', message: "Error: returned #{typeof evaled} instead of Object"}, event.origin)
  catch e
    event.source.postMessage({action: 'syntaxError', message: e.toString(), exception: JSON.stringify(e)}, event.origin)

getDefaultsFromGithub = (event) ->
  error = (e) ->
    event.source.postMessage({action: 'services', services: "# Could not load defaults from github :("}, event.origin)
    event.source.postMessage({action: 'defaultsError', error: JSON.stringify(e)}, event.origin)
  success = (defaults) ->
    event.source.postMessage({action: 'saveServices',    services: defaults}, event.origin)
    event.source.postMessage({action: 'defaultServices', services: defaults}, event.origin)
  $.ajax("https://raw.github.com/jayniz/not-my-department/master/defaults.jsonp",
    dataType: "jsonp"
    jsonpCallback: "bazinga"
    success:  success
    error:    error
    timeout:  10000
  )


# Resolve a keyword into a url
resolve = (event) ->
  lastEvent = event # We need this for helpers like alert
  fn = window.services[event.data.service]
  text = event.data.text
  postCallback = (url) ->
    event.source.postMessage({action: 'openUrl', url: url }, event.origin)
  url = fn(text, postCallback)
  if typeof url == "string"
    postCallback(url) 

# Respond to requests from the safe, cozy world of extensions,
# where no eval happens.
window.addEventListener 'message', (event) ->
  parseServices(event)         if event.data.action == 'services'
  resolve(event)               if event.data.action == 'resolve'
  getDefaultsFromGithub(event) if event.data.action == 'getDefaultServices'

