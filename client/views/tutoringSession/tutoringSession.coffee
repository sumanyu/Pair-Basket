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

  chatPartner: ->
    Session.get("chattingWith") || "Anonymous"

# Template.chatMessage.helpers 
#   user: ->completeSession
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
      userId: Session.get('userName')

    $(".chat-message").val ""

Template.chatBox.events 
  "keydown .chat-message": (e, s) ->
    if e.keyCode is 13
      e.preventDefault()
      sendMessage()

  "click #send": (e, s) ->
    sendMessage()

Template.tutoringSessionSidebar.helpers
  whiteboardIsSelected: ->
    Session.get('whiteboardIsSelected?')

  fileIsSelected: ->
    Session.get('fileIsSelected?')

  wolframIsSelected: ->
    Session.get('wolframIsSelected?')

Template.tutoringSessionPage.helpers
  whiteboardIsSelected: ->
    Session.get('whiteboardIsSelected?')

  fileIsSelected: ->
    Session.get('fileIsSelected?')

  wolframIsSelected: ->
    Session.get('wolframIsSelected?')

Template.tutoringSessionSidebar.events 
  "click .whiteboard-button": (e, s) ->
    Session.set('whiteboardIsSelected?', true)
    Session.set('fileIsSelected?', false)
    Session.set('wolframIsSelected?', false)

  "click .file-button": (e, s) ->
    Session.set('whiteboardIsSelected?', false)
    Session.set('fileIsSelected?', true)
    Session.set('wolframIsSelected?', false)

  "click .wolfram-button": (e, s) ->
    Session.set('whiteboardIsSelected?', false)
    Session.set('fileIsSelected?', false)
    Session.set('wolframIsSelected?', true)

  "click .end-session": (e, s) ->
    Session.set('foundTutor?', false)
    Session.set('waitingForTutor?', false)
    Session.set('askingQuestion?', false)
    
    Router.go('/dashboard')

Template.whiteBoard.rendered = ->
  # Ensures whiteboard layout has loaded before executing Deps.autorun
  Session.set("hasWhiteboardLoaded?", true)

  # Increment tutor's count
  Session.set("karma", Session.get('karma') + Session.get('karmaForCurrentQuestion'))
  Session.set('karmaForCurrentQuestion', null)

Template.whiteBoard.events
  'click .eraser': (e, s) ->
    pad.toggleModes()

  'click .clear-blackboard': (e, s) ->
    pad.wipe true     

pad = undefined
remotePad = undefined

Meteor.startup ->
  Deps.autorun ->
    if Session.get("hasWhiteboardLoaded?")
      if pad
        pad.close()
        remotePad.close()

      # Hot code bypasses hasWhiteboardLoaded?
      if $('canvas').length > 0
        user = Meteor.user()?._id || "Anonymous"

        sessionId = Session.get("sessionId")      
        pad = new Pad($('canvas'), sessionId, user)
        remotePad = new RemotePad(sessionId, pad)