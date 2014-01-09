synchronizedCloseAudioCalls = ->
  # Send message to remote peer to end her call as well
  ClassroomStream.emit "audioCallEnd:#{getChatPartner().id}", "Temporary message"

  # End local call
  closeAudioCalls()

# DON'T put these under audioCallContainer.rendered
# Because every time rendered is called, the fns are 
# Re-declared, but the old fns don't dissapear
# This causes conflict
Template.audioCallContainer.created = ->
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
    console.log "Getting audioCallRequest"
    # Check if classroomSessionId is valid
    if ClassroomSession.findOne({_id: classroomSessionId})
      # Update UI to show incoming call
      Session.set('incomingAudioCall?', true)  

  # Due to Meteor, we get multiple requests in short successions
  ClassroomStream.on "audioCallResponse:#{Meteor.userId()}", (audioResponse) ->
    console.log "Calling audioCallResponse: #{audioResponse}"

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
    console.log "Getting signal to audioCallEnd"
    # End call
    closeAudioCalls()

Template.audioCallContainer.helpers
  defaultAudioCall: ->
    Session.get('defaultAudioCall?') || false

  awaitingReplyForAudioCall: ->
    Session.get('awaitingReplyForAudioCall?') || false

  inAudioCall: ->
    Session.get('inAudioCall?') || false

Template.audioCallContainer.events
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