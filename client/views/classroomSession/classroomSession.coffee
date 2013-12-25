# This is called once when the page is created. We'll treat this as user joining the session.
Template.classroomSessionPage.created = ->
  console.log "Creating classroom session page"
  Meteor.call 'startClassroomSession', Session.get('classroomSessionId')

# This is called once when the classroom session is destroyed. It's not called if user goes to dashbaord.
# We'll treat this as user ending session
Template.classroomSessionPage.destroyed = ->
  console.log "Destroying classroom session page"

sendMessage = ->
  message = $(".chat-message").val()

  # Prevent empty messages
  if message.length > 0
    totalMessage = 
      message: message
      user:
        id: Meteor.userId()
        name: Meteor.user().profile.name
      type: 'normal'
      dateCreated: new Date

    console.log totalMessage

    # Push messages
    ClassroomSession.update {_id: Session.get('classroomSessionId')}, {$push: {messages: totalMessage}}

    $(".chat-message").val ""

Template.chatMessages.helpers
  areMessagesReady: ->
    getCurrentClassroomSession() || false

  messages: ->
    # fetch all chat messages
    getCurrentClassroomSession(['messages']).messages

  chatPartner: ->
    getChatPartner().name

Template.chatMessage.helpers
  isNormalMessage: ->
    @.type is 'normal'

Template.chatMessages.rendered = ->
  console.log "Chat messages re-rendering..."

  # Auto-scroll chat
  $('.chat-messages').scrollTop($('.chat-messages')[0].scrollHeight)

Template.chatBox.events 
  "keydown .chat-message": (e, s) ->
    if e.keyCode is 13
      e.preventDefault()
      sendMessage()

Template.chatBox.rendered = ->
  focusText($('.chat-message'))

Template.classroomSessionSidebar.helpers
  whiteboardIsSelected: ->
    Session.get('whiteboardIsSelected?')

  fileIsSelected: ->
    Session.get('fileIsSelected?')

  wolframIsSelected: ->
    Session.get('wolframIsSelected?')

Template.classroomSessionSidebar.events 
  "click .whiteboard-button": (e, s) ->
    Session.set('whiteboardIsSelected?', true)
    setSessionVarsWithValue false, ['fileIsSelected?', 'wolframIsSelected?']

  "click .file-button": (e, s) ->
    Session.set('fileIsSelected?', true)
    setSessionVarsWithValue false, ['whiteboardIsSelected?', 'wolframIsSelected?']

  "click .wolfram-button": (e, s) ->
    Session.set('wolframIsSelected?', true)
    setSessionVarsWithValue false, ['fileIsSelected?', 'whiteboardIsSelected?']

  "click .end-session": (e, s) ->
    setSessionVarsWithValue false , ['foundTutor?', 'askingQuestion?']

    Meteor.call 'endClassroomSession', Session.get("classroomSessionId"), (err, result) ->
      console.log "Calling end classroom session"

      if err
        console.log err
      else
        Router.go('/dashboard')

Template.classroomSessionPage.rendered = ->
  showActiveClassroomSessionTool()

Template.classroomSessionPage.events
  'click .start-audio': (e, s) ->
    # Send user's id for now
    # ClassroomStream.emit "audioRequest:#{getChatPartner().id}", Session.get("classroomSessionId")
    
    # For data connections
    # conn = peer.connect("#{getChatPartner.id}")

    console.log 

    # For calls
    navigator.getUserMedia {audio: true}, ((mediaStream) ->
      console.log "Local media stream"
      console.log mediaStream

      call = peer.call("#{getChatPartner().id}", mediaStream)

      console.log call

      call.on 'stream', playRemoteStream

      ), (err) -> console.log "Failed to get local streams", err

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
