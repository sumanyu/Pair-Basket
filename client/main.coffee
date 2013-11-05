# Get subscriptions

Meteor.startup ->
  Session.set("questions_loaded", false)

Meteor.subscribe "questions", ->
  Session.set("questions_loaded", true)