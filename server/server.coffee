Meteor.startup ->
  console.log "Server is starting!"

Meteor.publish "questions", (status) ->
  Messages.find status: status