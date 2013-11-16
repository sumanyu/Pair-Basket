# Temporary local chat collection
chatCollection = new Meteor.Collection(null)

# ChatStream.on "chat", (message) ->
#   chatCollection.insert
#     userId: message.userId
#     message: message.message

test = 0

Template.chatBox.helpers 
  messages: ->
    # fetch all chat messages
    console.log "Testing #{test}"
    console.log TutoringSession.findOne()
    messages = TutoringSession.findOne({}, {fields: {messages: 1}}).messages
    test = test + 1
    messages

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
    totalMessage = 
      message: message
      userId: Meteor.userId()

    tutoringSessionId = TutoringSession.findOne()._id

    # Push messages
    TutoringSession.update {_id: tutoringSessionId}, $push: {messages: totalMessage}

    console.log TutoringSession.findOne()

    # chatCollection.insert
    #   userId: "me"
    #   message: message

    # # Broadcast that message to all clients
    # ChatStream.emit "chat", 
    #   message: message
    #   userId: Session.get('userName')

    $(".chat-message").val ""

Template.chatBox.events 
  "keydown .chat-message": (e, s) ->
    if e.keyCode is 13
      e.preventDefault()
      console.log "entering?"
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
    Session.set('askingQuestion?', false)
    
    Router.go('/dashboard')

Template.whiteBoard.rendered = ->
  # Ensures whiteboard layout has loaded before executing Deps.autorun
  Session.set("hasWhiteboardLoaded?", true)

Template.whiteBoard.events
  'click .draw': (e, s) ->
    pad.startDrawMode()

  'click .erase': (e, s) ->
    pad.startEraseMode()

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
