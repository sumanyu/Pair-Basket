Template.otherQuestionTile.events =
  'click .accept-question' : (e, selector) ->
    e.preventDefault()
    console.log "Accepting Question"  

    questionId = @._id

    # Prevent from accepting your own question
    if String(Session.get("subscribedQuestion")).valueOf() != String(questionId).valueOf()

      # User Meteor method to notify client
      Meteor.call "createSessionRequest", questionId, (err, result) ->
        console.log "SessionRequestCreated"

        if err
          console.log err
        else
          # Use event emitter to signal question owner that I've accepted her question
          ClassroomStream.emit "request:#{questionId}", result
          Session.set("subscribedResponse", result)

          # Session.set("subscribedQuestionResponse", SessionRequest.findOne({userId: Meteor.userId()})?.questionId)

# Event listener for listening for classroom requests
Deps.autorun ->
  if Session.get('subscribedResponse')
    ClassroomStream.on "response:#{Session.get('subscribedResponse')}", (message) ->
      console.log message
      console.log "That person started the tutoring session!"

# # subscribedQuestionResponse will ALWAYS have the value of the subscribed session request
# Deps.autorun ->
#   if Meteor.userId()
#     Session.set("subscribedQuestionResponse", SessionRequest.findOne({userId: Meteor.userId()})?.questionId)