# Get subscriptions

Meteor.startup ->
  Session.set("questions_loaded", false)

Meteor.subscribe "questions", ->
  # Set variable in case collection isn't loaded in time for rendering
  Session.set("questions_loaded", true)