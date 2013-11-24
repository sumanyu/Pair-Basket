Template.otherQuestionTile.events =
  'click .accept-question' : (e, selector) ->
    e.preventDefault()
    console.log "Accepting Question"  

    questionId = @._id

    # Add more security later

    console.log "createSessionRequest"

    # Send my userId to person who wants my help
    ClassroomStream.emit "request:#{questionId}", Meteor.userId()
    Session.set("subscribedResponse", Meteor.userId())