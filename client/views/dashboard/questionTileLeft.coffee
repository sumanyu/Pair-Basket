# Is this even being used?

Template.questionTileLeft.events =
  'click .accept-question' : (e, selector) ->
    e.preventDefault()
    console.log "Accepting Question"  

    questionId = @._id

    # Make sure you can't accept your own question
    if String(Session.get("subscribedQuestion")).valueOf() != String(questionId).valueOf()

      # User Meteor method to notify client
      Meteor.call("createSessionRequest", questionId, (err, result) ->
        console.log "SessionRequestCreated"
      )
      
      # Auto run should auto-set this
      # Session.set("subscribedQuestionResponse", questionId)

Deps.autorun ->
  if SessionRequest.findOne({userId: Meteor.userId()})
    Session.set("subscribedQuestionResponse", SessionRequest.findOne({userId: Meteor.userId()}).questionId)