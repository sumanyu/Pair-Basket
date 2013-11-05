# Manages client to client communication
chatStream = new Meteor.Stream("chat")

# Temporary local chat collection
chatCollection = new Meteor.Collection(null)

chatStream.on "chat", (message) ->
  chatCollection.insert
    userId: @userId
    message: message

Template.chatBox.helpers 
  messages: ->
    # fetch all chat messages
    chatCollection.find()

Template.chatMessage.helpers 
  user: ->
    @userId

sendMessage = ->
  message = $("#chat-message").val()

  chatCollection.insert
    userId: "me"
    message: message

  # Broadcast that message to all clients
  chatStream.emit "chat", message
  $("#chat-message").val ""

Template.chatBox.events 
  "keydown #chat-message": (e, s) ->
    if e.keyCode is 13
      e.preventDefault()
      sendMessage()

  "click #send": (e, s) ->
    sendMessage()