Template.question.events =
  'click .accept-question' : (e, selector) ->
    e.preventDefault()
    console.log "Accepting Question"  

    questionId = @._id

    # User Meteor method to notify client
    Meteor.call("createSessionRequest", questionId, (err, result) ->
      console.log "SessionRequestCreated"
    )

    Session.set("subscribedQuestionResponse", questionId)