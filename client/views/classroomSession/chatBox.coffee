sendMessage = ->
  message = $(".input-chat-message").val()

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

    $(".input-chat-message").val ""

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
  "keydown .input-chat-message": (e, s) ->
    if e.keyCode is 13
      e.preventDefault()
      sendMessage()

  'click .start-call': (e, s) ->
    # Send request to start audio session
    # Emit to other user's userID and send classroomSessionId to ensure audiochat is valid
    # TODO: Use something less sensitive than userId when sending these messages
    ClassroomStream.emit "audioCallRequest:#{getChatPartner().id}", Session.get("classroomSessionId")
    
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

    synchronizedCloseAudioCalls()

  "click .accept-incoming-audio-call": ->
    console.log "Accepting incoming audio call" 

    # Notify other user you want to accept call
    ClassroomStream.emit "audioCallResponse:#{getChatPartner().id}", true

    # Now in call
    Session.set('inAudioCall?', true)
    setSessionVarsWithValue false, [
      'incomingAudioCall?',
      'awaitingReplyForAudioCall?',
      'defaultAudioCall?'
    ]

  "click .decline-button": ->
    console.log "Reject incoming audio call"

    # Notify other user you want to reject call
    ClassroomStream.emit "audioCallResponse:#{getChatPartner().id}", false

    # No longer in call
    Session.get('defaultAudioCall?', true)
    setSessionVarsWithValue false, [
      'awaitingReplyForAudioCall?',
      'inAudioCall?',
      'incomingAudioCall?'
    ]

synchronizedCloseAudioCalls = ->
  # Send message to remote peer to end her call as well
  ClassroomStream.emit "audioCallEnd:#{getChatPartner().id}", "Temporary message"

  # End local call
  closeAudioCalls()

Template.chatBox.rendered = ->
  focusText($('.input-chat-message'))

  # Callback for when peerJS successfully loads
  peer.on 'open', (id) ->
    # Testing that peer is actually working
    console.log "My id is: #{id}"

  # Callback for when peerJS has initialization errors
  peer.on 'error', (err) ->
    console.log "PeerJS initialization error"
    console.log err

  # When you're getting a call
  peer.on 'call', (_call) ->
    console.log "Getting a call"
    console.log _call

    remoteCall = _call

    # Open user's local mediastream, ready to be sent to the caller
    navigator.getUserMedia(
      {audio: true},
      ((mediaStream) ->
        # When mediaStream loads, answer the call, providing our mediaStream
        remoteCall.answer(mediaStream)

        # When remove user is streaming, play it right away
        remoteCall.on 'stream', (remoteStream) ->
          console.log remoteStream
          playRemoteStream(remoteStream)  
      ), 
      ((err) -> console.log "This is my error: ", err)
    )

  # Activate stream events
  ClassroomStream.on "audioCallRequest:#{Meteor.userId()}", (classroomSessionId) ->
    # Check if classroomSessionId is valid
    if ClassroomSession.findOne({_id: classroomSessionId})
      # Update UI to show incoming call
      Session.set('incomingAudioCall?', true)  

  ClassroomStream.on "audioCallResponse:#{Meteor.userId()}", (audioResponse) ->
    console.log "Getting response from audio call request"

    if audioResponse

      # Update UI
      Session.set('inAudioCall?', true)
      setSessionVarsWithValue false, [
        'awaitingReplyForAudioCall?',
        'defaultAudioCall?'
      ]

      # Prevent multiple calls
      unless call
        # Call remote user
        console.log "Calling remote user"
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
      Session.set('defaultAudioCall?', true)
      setSessionVarsWithValue false, [
        'awaitingReplyForAudioCall?',
        'inAudioCall?'
      ]

  ClassroomStream.on "audioCallEnd:#{Meteor.userId()}", (message) ->
    # End call
    closeAudioCalls()

Template.chatBox.helpers
  defaultAudioCall: ->
    Session.get('defaultAudioCall?') || false

  awaitingReplyForAudioCall: ->
    Session.get('awaitingReplyForAudioCall?') || false

  inAudioCall: ->
    Session.get('inAudioCall?') || false

  incomingAudioCall: ->
    Session.get('incomingAudioCall?') || false