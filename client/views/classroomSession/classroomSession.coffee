# This is called once when the page is created. We'll treat this as user joining the session.
Template.classroomSessionPage.created = ->
  console.log "Creating classroom session page"
  Meteor.call 'enterClassroomSession', Session.get('classroomSessionId')

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
  isNormalMessage: ->y
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

  'click .start-call': (e, s) ->
    # Send request to start audio session
    # Emit to other user's userID and send classroomSessionId to ensure audiochat is valid
    # TODO: Use something less sensitive than userId when sending these messages
    ClassroomStream.emit "audioCallInitRequest:#{getChatPartner().id}", Session.get("classroomSessionId")
    
    # Update UI while we wait for the response
    Session.set("awaitingReplyForAudioCall?", true)
    setSessionVarsWithValue false, [
      'inAudioCall?',
      'defaultAudioCall?'
    ]

  'click .end-call': (e, s) ->
    # Update UI to end call
    Session.set('defaultAudioCall?', true)
    setSessionVarsWithValue false, [
      'inAudioCall?',
      'awaitingReplyForAudioCall?'
    ]

    # Send message to remote peer to end her call as well
    ClassroomStream.emit "audioCallEnd:#{getChatPartner().id}", Session.get("classroomSessionId")

Template.chatBox.rendered = ->
  focusText($('.chat-message'))

  # Activate stream events
  ClassroomStream.on "audioCallInitRequest:#{Meteor.userId()}", (classroomSessionId) ->
    # Check if classroomSessionId is valid
    if ClassroomSession.findOne({_id: classroomSessionId})
      # Update UI to show incoming call
      Session.set('incomingAudioCall?', true)  

  ClassroomStream.on "audioCallInitResponse:#{Meteor.userId()}", (audioResponse) ->
    if audioResponse
      # Call remote user
      navigator.getUserMedia {audio: true}, ((mediaStream) ->
        console.log "Local media stream"
        console.log mediaStream

        call = peer.call("#{getChatPartner().id}", mediaStream)

        if call
          # Update UI call succeeded
          Session.get('awaitingReplyForAudioCall?', false)
          Session.get('inAudioCall?', true)

        call.on 'stream', playRemoteStream

        ), (err) -> console.log "Failed to get local streams", err
    else
      # Update UI call failed
      setSessionVarsWithValue false, [
        'awaitingReplyForAudioCall?',
        'inAudioCall?'
      ]
      
Template.chatBox.helpers
  defaultAudioCall: ->
    Session.get('defaultAudioCall?') || false

  awaitingReplyForAudioCall: ->
    Session.get('awaitingReplyForAudioCall?') || false

  inAudioCall: ->
    Session.get('inAudioCall?') || false

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