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

Template.chatBox.rendered = ->
  focusText($('.input-chat-message'))

  # Hack to make chat full screen. Fix this later.
  # Set that height to chat-messages
  $('.chat-messages').height(window.innerHeight - 215)

Template.incomingCallContainer.events
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

Template.incomingCallContainer.helpers
  incomingAudioCall: ->
    Session.get('incomingAudioCall?') || false