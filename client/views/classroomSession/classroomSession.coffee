Template.chatBox.helpers
  areMessagesReady: ->
    ClassroomSession.findOne({}) || false

  messages: ->
    # fetch all chat messages
    ClassroomSession.findOne({}, {fields: {messages: 1}}).messages

  chatPartner: ->
    currentUser = Meteor.userId()
    currentSession = ClassroomSession.findOne({}, {fields: {tutorId: 1, tuteeId: 1}})
    tutorId = currentSession.tutorId
    tuteeId = currentSession.tuteeId

    if currentUser is tutorId then tuteeId else tutorId

sendMessage = ->
  message = $(".chat-message").val()

  # Prevent empty messages
  if message.length > 0
    totalMessage = 
      message: message
      userId: Meteor.userId()

    classroomSessionId = ClassroomSession.findOne()._id

    console.log ClassroomSession.findOne()

    # Push messages
    ClassroomSession.update {_id: classroomSessionId}, $push: {messages: totalMessage}

    console.log ClassroomSession.findOne()

    $(".chat-message").val ""

Template.chatBox.events 
  "keydown .chat-message": (e, s) ->
    if e.keyCode is 13
      e.preventDefault()
      console.log "entering?"
      sendMessage()

  "click #send": (e, s) ->
    sendMessage()

Template.classroomSessionSidebar.helpers
  whiteboardIsSelected: ->
    Session.get('whiteboardIsSelected?')

  fileIsSelected: ->
    Session.get('fileIsSelected?')

  wolframIsSelected: ->
    Session.get('wolframIsSelected?')

Template.classroomSessionPage.helpers
  whiteboardIsSelected: ->
    Session.get('whiteboardIsSelected?')

  fileIsSelected: ->
    Session.get('fileIsSelected?')

  wolframIsSelected: ->
    Session.get('wolframIsSelected?')

Template.classroomSessionSidebar.events 
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

    Meteor.call 'endSession', Session.get("classroomSessionId"), (err, result) ->
      console.log "Calling end classroom session"

      if err
        console.log err
      else
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

      # Hot code bypasses `hasWhiteboardLoaded?`
      if $('canvas').length > 0
        user = Meteor.user()?._id || "Anonymous"

        classroomSessionId = Session.get("classroomSessionId")
        pad = new Pad($('canvas'), classroomSessionId, user)
        remotePad = new RemotePad(classroomSessionId, pad)
