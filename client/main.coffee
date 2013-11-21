# Get subscriptions

Meteor.startup ->

  console.log "Meteor startup start"

  Meteor.subscribe 'users'

  Meteor.subscribe 'questions', ->
    console.log "Subscribed to Questions"
    Session.set("hasQuestionsLoaded?", true)

    # Subscribed question will always hold the subscribed question
    Session.set("subscribedQuestion", Questions.findOne({userId: Meteor.userId()})?._id) 

  Meteor.subscribe 'tutoringSession', ->
    console.log "Subscibred to tutoring session"

    tutoringSession = TutoringSession.findOne()

    console.log "Current tutoring session: #{tutoringSession}"

    # If pending tutoringSession, go straight to the session
    if tutoringSession
      Session.set("sessionId", tutoringSession.sessionId)
      Router.go('/session/#{tutoringSession.sessionId}')

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

  # category filter
  Session.set('categoryFilter', {
    'math': true,
    'science': true,
    'english': true,
    'social_science': false,
    'computer': true,
    'business': false,
    'foreign_language': false
  })

  console.log "Meteor startup end"

  # Deps.autorun ->
  #   if Session.get("subscribedQuestion")
  #     Meteor.subscribe "sessionRequest", Session.get("subscribedQuestion")

  # Deps.autorun ->
  #   if Session.get("subscribedQuestionResponse")
  #     Meteor.subscribe "sessionResponse", Session.get("subscribedQuestionResponse")
      
  # Deps.autorun ->
  #   # If tutee accepted tutor's request
  #   if SessionResponse.find({}).count() > 0
  #     console.log "SessionResponse autorun"
  #     response = SessionResponse.findOne()

  #     console.log response

  #     Session.set('foundTutor?', false)

  #     Meteor.subscribe 'tutoringSession', response.sessionId, (arg) ->
  #       console.log arg
  #       console.log @
  #       Router.go("/session/#{response.sessionId}")

  # Deps.autorun -> 
  #   # if tutor accepted the request
  #   if SessionRequest.find({}).count() > 0
  #     console.log "SessionRequest autorun"      
  #     console.log SessionRequest.findOne()

  #     # Popup tutor
  #     Session.set('foundTutor?', true)

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

  # Event listener for listening for classroom requests
  Deps.autorun ->
    if Session.get('subscribedQuestion')
      ClassroomStream.on "request:#{Session.get('subscribedQuestion')}", (secretId) ->
        console.log "Someone clicked accept to my question; their secret id: #{secretId}"
        Session.set('subscribedResponse', secretId)
        Session.set('foundTutor?', true)

  # Event listener for listening for classroom requests
  Deps.autorun ->
    if Session.get('subscribedResponse')
      ClassroomStream.on "response:#{Session.get('subscribedResponse')}", (session) ->
        console.log "That person started the tutoring session!; sessionId: #{session}"
        Router.go("/session/#{session}")