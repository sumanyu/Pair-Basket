Template.otherQuestionTile.events =
  'click .accept-question' : (e, selector) ->
    e.preventDefault()
    console.log "Accepting Question"  

    questionId = @._id

    if String(Session.get("subscribedQuestion")).valueOf() != String(questionId).valueOf()

      # User Meteor method to notify client
      Meteor.call "createSessionRequest", questionId, (err, result) ->
        console.log "SessionRequestCreated"

        if err
          console.log err
        else
          # Use event emitter to signal question owner that someone has accepted your question
          Session.set("subscribedQuestionResponse", SessionRequest.findOne({userId: Meteor.userId()})?.questionId)

# subscribedQuestionResponse will ALWAYS have the value of the subscribed session request
Deps.autorun ->
  if Meteor.userId()
    Session.set("subscribedQuestionResponse", SessionRequest.findOne({userId: Meteor.userId()})?.questionId)