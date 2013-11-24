# Get subscriptions

Meteor.startup ->

  console.log "Meteor startup start"

  #### Begin Session variables

  # Pending session that user left unended should redirect to session itself
  Session.set('pendingSession?', false)

  # Has non-null value if question comes from the landing page prompt
  Session.set('questionFromLandingPrompt', null)

  # Ensure questions has loaded
  Session.set("hasQuestionsLoaded?", false)

  # Ensure TutoringSession collection has loaded
  Session.set("hasTutoringSessionCollectionLoaded?", false)

  # Ensure Users collection had loaded
  Session.set("hasUsersLoaded?", false)

  # Ensure all collections have loaded before performing some action
  Session.set('haveAllCollectionsLoaded?', false)

  # Ensure whiteboard has loaded
  Session.set("hasWhiteboardLoaded?", false)

  # Click feedback button
  Session.set('feedbackPopup', false)

  # Is the client asking a question?
  Session.set('askingQuestion?', false)

  # Error message for ask question
  Session.get('questionFormError', null)

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

  #### End Session variables

  #### Begin Subscriptions

  Meteor.subscribe('users', ->
    console.log "Subscribed to users"
    Session.set("hasUsersLoaded?", true))

  Meteor.subscribe 'questions', ->
    console.log "Subscribed to Questions"
    Session.set("hasQuestionsLoaded?", true)

    # Subscribed question will always hold the subscribed question
    Session.set("subscribedQuestion", Questions.findOne({userId: Meteor.userId()})?._id) 

  Meteor.subscribe('tutoringSession', ->
    console.log "Subscribed to tutoring session"
    Session.set("hasTutoringSessionCollectionLoaded?", true)

    tutoringSession = TutoringSession.findOne()

    console.log "Current tutoring session: #{tutoringSession}"
    console.log "Tutoring session count: #{TutoringSession.find().count()}"

    # If pending tutoringSession, go straight to the session
    if TutoringSession.find().count() > 0
      console.log "Count is greater than 0, redirecting..."
      Session.set("sessionId", tutoringSession.sessionId)
      Session.set('pendingSession?', true))

  #### End Subscriptions

  #### Begin autoruns

  # Ensure all collections have loaded before performing action
  Deps.autorun ->
    tests = [
      'hasTutoringSessionCollectionLoaded?', 
      'hasQuestionsLoaded?', 
      'hasUsersLoaded?'
    ]

    result = tests.map((test) -> Session.get(test)).reduce((total, test) -> test and total)
    console.log "Running ensuring all collections have loaded: #{result}"
    Session.set('haveAllCollectionsLoaded?', result)

  # Show whiteboard, hide other things
  Deps.autorun ->
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

  # Automatically redirect user to session if user had a session open and didn't end it properly
  # Deps.autorun ->
  #   if Session.get('pendingSession?')
  #     Router.go("/session/#{Session.get("sessionId")}")

  #### End autoruns

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

  console.log "Meteor startup end"
