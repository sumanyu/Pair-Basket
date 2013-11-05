# Get subscriptions

Meteor.startup ->
  # Used for questions board
  Session.set("hasQuestionsLoaded?", false)

  # Used for whiteboard
  Session.set("hasWhiteboardLoaded?", false)  

Meteor.subscribe "questions", ->
  # Set variable in case collection isn't loaded in time for rendering
  Session.set("hasQuestionsLoaded?", true)