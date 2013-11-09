# Get subscriptions

Meteor.startup ->
  # Has non-null value if question comes from the landing page prompt
  Session.set('questionFromLandingPrompt', null)

  # Ensure questions has loaded
  Session.set("hasQuestionsLoaded?", false)

  # Ensure whiteboard has loaded
  Session.set("hasWhiteboardLoaded?", false)

  # Is the client asking a question?
  Session.set('askingQuestion?', false)

  # Is the client waiting for a tutor?
  Session.set('waitingForTutor?', false)

  # Has the client found a tutor? If so, prompt user to accept/decline tutor's request
  Session.set('foundTutor?', false)

  # Subscribe user to user's asked question ID
  Session.set('subscribedQuestion', null)

  # Subscribe user to user's asked question ID
  Session.set('subscribedQuestionResponse', null)

  Deps.autorun ->
    if Session.get("subscribedQuestion")
      Meteor.subscribe "sessionRequest", Session.get("subscribedQuestion")

    if Session.get("subscribedQuestionResponse")
      Meteor.subscribe "sessionResponse", Session.get("subscribedQuestionResponse")
      
    # If tutee accepted tutor's request
    if SessionResponse.find({}).count() > 0
      response = SessionResponse.findOne()
      Session.set('foundTutor?', false)
      Router.go("/session/#{response.sessionId}")

    # if tutor accepted the request
    if SessionRequest.find({}).count() > 0
      # Popup tutor
      Session.set('foundTutor?', true)

  Meteor.subscribe "questions", ->
    # Set variable in case collection isn't loaded in time for rendering
    Session.set("hasQuestionsLoaded?", true)