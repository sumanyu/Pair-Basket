Template.otherQuestionTile.events =
  'click .accept-question' : (e, selector) ->
    e.preventDefault()
    console.log "Accepting Question"  

    questionId = @._id

    if String(Session.get("subscribedQuestion")).valueOf() != String(questionId).valueOf()

      # User Meteor method to notify client
      Meteor.call("createSessionRequest", questionId, Meteor.user(), (err, result) ->
        console.log "SessionRequestCreated"
      )
      
      Session.set("subscribedQuestionResponse", questionId)
      # @.karmaOffered