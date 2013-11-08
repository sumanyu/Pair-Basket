# Get subscriptions

Meteor.startup ->
  # Used for questions board
  Session.set("hasQuestionsLoaded?", false)

  # Used for whiteboard
  Session.set("hasWhiteboardLoaded?", false)

  Deps.autorun ->
    if Session.get("currentQuestion")
      Meteor.subscribe "sessionRequest", Session.get("currentQuestion")

    # if someone accepted the request
    if SessionRequest.find({}).count() > 0
      # Popup tutor
      Session.set('foundTutor', true)

  Meteor.subscribe "questions", ->
    # Set variable in case collection isn't loaded in time for rendering
    Session.set("hasQuestionsLoaded?", true)