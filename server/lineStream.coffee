#map subscriptionId and the padId is listening to
subscriptionPadsMap = {}

LineStream.on "pad", (padId) ->
  
  console.log @

  # subscriptionId is unique ID of the sending client
  subscriptionId = @subscriptionId
  subscriptionPadsMap[subscriptionId] = padId

  @onDisconnect = ->
    subscriptionPadsMap[subscriptionId] = undefined

LineStream.permissions.read ((event) ->
  
  #getting padId from the event
  matched = event.match(/(.*):/)

  if matched
    padId = matched[1]
    
    #only allow events with padId where subscription is interestedIn
    subscriptionPadsMap[@subscriptionId] is padId
  else
    #only allows events with padId to read from the stream
    false
    
), false

LineStream.permissions.write (event) ->
  true