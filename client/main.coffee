# Get subscriptions

Meteor.startup ->

  Meteor.subscribe 'users'

  Meteor.subscribe 'questions', ->
    Session.set("hasQuestionsLoaded?", true)  

  # Has non-null value if question comes from the landing page prompt
  Session.set('questionFromLandingPrompt', null)

  # Ensure questions has loaded
  Session.set("hasQuestionsLoaded?", false)

  # Ensure whiteboard has loaded
  Session.set("hasWhiteboardLoaded?", false)

  # Is the client asking a question?
  Session.set('askingQuestion?', false)

  # Has the client found a tutor? If so, prompt user to accept/decline tutor's request
  Session.set('foundTutor?', false)

  # Subscribe user to user's asked question ID
  Session.set('subscribedQuestion', null)

  # Subscribe user to user's asked question ID
  Session.set('subscribedQuestionResponse', null)

  # Session sidebar variables
  Session.set('whiteboardIsSelected?', true)
  Session.set('fileIsSelected?', false)
  Session.set('wolframIsSelected?', false)

  # Alert the user she doesn't have enough Karma
  Session.set('showNotEnoughKarma?', false)

  # Set temporary userName
  Session.set('userName', 'Kelly')

  # Chatting with whom in whiteboard session
  Session.set('chattingWith', null)

  # Landing Session variables
  Session.set('helpOthers?', false)
  Session.set('askQuestion?', false)
  Session.set('showBoth?', true)

  Deps.autorun ->
    if Session.get("subscribedQuestion")
      Meteor.subscribe "sessionRequest", Session.get("subscribedQuestion")

  Deps.autorun ->
    if Session.get("subscribedQuestionResponse")
      Meteor.subscribe "sessionResponse", Session.get("subscribedQuestionResponse")
      
  Deps.autorun ->
    # If tutee accepted tutor's request
    if SessionResponse.find({}).count() > 0
      console.log "SessionResponse autorun"
      response = SessionResponse.findOne()

      console.log response

      Session.set('foundTutor?', false)

      Meteor.subscribe 'tutoringSession', response.sessionId, ->

        console.log TutoringSession.find().fetch()

        Meteor.call 'cancelSessionResponse', response.questionId, (err, result) ->
          if err
            console.log err
          else
            Router.go("/session/#{response.sessionId}")

  Deps.autorun -> 
    # if tutor accepted the request
    if SessionRequest.find({}).count() > 0
      console.log "SessionRequest autorun"      
      console.log SessionRequest.findOne()

      # Popup tutor
      Session.set('foundTutor?', true)

  # Deps.autorun ->
  #   # Takes time for message to propogate between subscription and delivery
  #   if TutoringSession.find({}).count() > 0
  #     console.log "TutoringSession autorun"   
  #     tutoringSession = TutoringSession.findOne()

  #     console.log tutoringSession

  #     sessionId = tutoringSession.sessionId

  #     console.log "Entering tutoring session page"
      

  Deps.autorun ->
    # Show whiteboard, hide other things
    if Session.get('whiteboardIsSelected?')
      $('.whiteboard').show()
      $('.sharingFiles').hide()
      $('.wolfram').hide()

    if Session.get('fileIsSelected?')
      $('.whiteboard').hide()
      $('.sharingFiles').show()
      $('.wolfram').hide()    

    if Session.get('wolframIsSelected?')
      $('.whiteboard').hide()
      $('.sharingFiles').hide()
      $('.wolfram').show()