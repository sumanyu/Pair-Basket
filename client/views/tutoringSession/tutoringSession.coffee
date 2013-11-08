# Manages client to client communication
chatStream = new Meteor.Stream("chat")

@LineStream = new Meteor.Stream("lines")

# Temporary local chat collection
chatCollection = new Meteor.Collection(null)

chatStream.on "chat", (message) ->
  chatCollection.insert
    userId: message.userId
    message: message.message

Template.chatBox.helpers 
  messages: ->
    # fetch all chat messages
    chatCollection.find()

# Template.chatMessage.helpers 
#   user: ->
#     # console.log userId
#     console.log @
#     console.log @userId

sendMessage = ->
  message = $(".chat-message").val()

  # Prevent empty messages
  if message.length > 0
    chatCollection.insert
      userId: "me"
      message: message

    # Broadcast that message to all clients
    chatStream.emit "chat", 
      message: message
      userId: "Davin"

    $(".chat-message").val ""
    console.log $('.chat-message').val()

Template.chatBox.events 
  "keydown .chat-message": (e, s) ->
    if e.keyCode is 13
      e.preventDefault()
      sendMessage()

  "click #send": (e, s) ->
    sendMessage()

Template.whiteBoard.rendered = ->
  # Ensures whiteboard layout has loaded before executing Deps.autorun
  Session.set("hasWhiteboardLoaded?", true)

pad = undefined
remotePad = undefined

Meteor.startup ->
  Deps.autorun ->
    if Session.get("hasWhiteboardLoaded?")
      if pad
        pad.close()
        remotePad.close()

      sessionId = Session.get("sessionId")      
      pad = new Pad(sessionId)
      remotePad = new RemotePad(sessionId, pad)