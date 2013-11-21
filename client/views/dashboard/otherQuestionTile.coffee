Template.otherQuestionTile.events =
  'click .accept-question' : (e, selector) ->
    e.preventDefault()
    console.log "Accepting Question"  

    questionId = @._id

    # Add more security later

    console.log "createSessionRequest"
    ClassroomStream.emit "request:#{questionId}", Meteor.userId()
    Session.set("subscribedResponse", Meteor.userId())

    # # User Meteor method to notify client
    # Meteor.call "createSessionRequest", questionId, (err, responseId) ->
    #   console.log "createSessionRequest"

    #   if err
    #     console.log "Error..." 
    #     console.log err
    #   else
    #     console.log "Responseid: #{responseId}"

    #     # Use event emitter to signal question owner that I've accepted her question
    #     ClassroomStream.emit "request:#{questionId}", responseId
    #     Session.set("subscribedResponse", responseId)

          # Session.set("subscribedQuestionResponse", SessionRequest.findOne({userId: Meteor.userId()})?.questionId)

# Event listener for listening for classroom requests
Deps.autorun ->
  if Session.get('subscribedResponse')
    ClassroomStream.on "response:#{Session.get('subscribedResponse')}", (session) ->
      console.log "That person started the tutoring session!; sessionId: #{session}"
      Router.go("/session/#{session}")

# # subscribedQuestionResponse will ALWAYS have the value of the subscribed session request
# Deps.autorun ->
#   if Meteor.userId()
#     Session.set("subscribedQuestionResponse", SessionRequest.findOne({userId: Meteor.userId()})?.questionId)