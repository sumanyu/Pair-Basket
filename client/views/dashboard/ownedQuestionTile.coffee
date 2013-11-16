Template.ownedQuestionTile.events =
  'click .cancel-question' : (e, selector) ->
    e.preventDefault()
    console.log "Canceling Question"  

    questionId = @._id

    Meteor.call("cancelOwnedQuestion", questionId, (err, result) ->
      console.log "Cancelled Question"
    )