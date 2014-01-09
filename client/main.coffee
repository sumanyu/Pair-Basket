# Get subscriptions

Meteor.startup ->

  console.log "Meteor startup start"

  #### Begin Session variables

  setSessionVarsWithValue false, [
    # Pending session that user left unended should redirect to session itself
    'pendingSession?'

    # Ensure skills has loaded
    'hasSkillsCollectionLoaded?'

    # Ensure questions has loaded
    'hasQuestionsCollectionLoaded?'

    # Ensure ClassroomSession collection has loaded
    'hasClassroomSessionCollectionLoaded?'

    # Ensure Users collection had loaded
    'hasUsersCollectionLoaded?'

    # Ensure all collections have loaded before performing some action
    'haveAllCollectionsLoaded?'

    # Click feedback button
    'feedbackPopup?'

    # Is the client asking a question?
    'askingQuestion?'

    # Has the client found a tutor? If so, prompt user to accept/decline tutor's request
    'foundTutor?'

    # Alert the user she doesn't have enough Karma
    'showNotEnoughKarma?'

    # Profile: toggle skill
    'editingSkills?'

    # Waiting for reply for audio call
    'awaitingReplyForAudioCall?'

    # Currently in audio call
    'inAudioCall?'

    # Incoming audio call?
    'incomingAudioCall?'
  ]

  setSessionVarsWithValue true, [
    # Default audioCall action (no action yet)
    'defaultAudioCall?'
  ]  

  setSessionVarsWithValue null, [
    # Has non-null value if question comes from the landing page prompt
    'questionFromLandingPrompt'

    # Error message for ask question
    'questionFormError'

    # Subscribe user to user's asked question ID
    'subscribedQuestion'

    # Subscribe user to user's asked question ID
    'subscribedQuestionResponse'

    # Active classroom session Id
    'classroomSessionId'

    # Profile Page: user.profile of user being browsed
    'profile'
  ]

  # Session sidebar variables
  Session.set('whiteboardIsSelected?', true)
  setSessionVarsWithValue false, ['fileIsSelected?', 'wolframIsSelected?']

  # Landing Session variables
  Session.set('showBoth?', true)
  setSessionVarsWithValue false, ['helpOthers?', 'askQuestion?']


  #### End Session variables

  #### Begin Subscriptions

  Meteor.subscribe 'users', ->
    console.log "Subscribed to users"
    Session.set("hasUsersCollectionLoaded?", true)

  Meteor.subscribe 'skills', ->
    console.log "Subscribed to skills"
    Session.set("hasSkillsCollectionLoaded?", true)

  Meteor.subscribe 'questions', ->
    console.log "Subscribed to Questions"
    Session.set("hasQuestionsCollectionLoaded?", true)

    # Subscribed question will always hold the subscribed question
    Session.set("subscribedQuestion", Questions.findOne({userId: Meteor.userId()})?._id)

  # Deps.autorun below will handle setting classroomSessionId
  Meteor.subscribe 'classroomSession', ->
    console.log "Subscribed to classroom session"
    Session.set("hasClassroomSessionCollectionLoaded?", true)

  #### End Subscriptions

  #### Begin autoruns

  # Ensure all collections have loaded before performing action
  Deps.autorun ->
    tests = [
      'hasClassroomSessionCollectionLoaded?', 
      'hasQuestionsCollectionLoaded?', 
      'hasUsersCollectionLoaded?',
      "hasSkillsCollectionLoaded?"
    ]

    result = tests.map((test) -> Session.get(test)).reduce((total, test) -> test and total)
    console.log "Running ensuring all collections have loaded: #{result}"
    Session.set('haveAllCollectionsLoaded?', result)

  # Show whiteboard, hide other things
  Deps.autorun ->
    showActiveClassroomSessionTool()

  # Ensure 'classroomSessionId' is set to current classroom session ID
  Deps.autorun ->
     # If pending ClassroomSession, go straight to the session
    if ClassroomSession.findOne()
      console.log "Pending classroom session exists. Setting classroomSessionId to #{ClassroomSession.findOne()._id}"
      Session.set("classroomSessionId", ClassroomSession.findOne()._id)
    else
      Session.set("classroomSessionId", null)

  Deps.autorun ->
    console.log "Reactive: haveAllCollectionsLoaded? #{Session.get('haveAllCollectionsLoaded?')}"

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

  # If logged in, set user's question category filters
  Deps.autorun ->
    categoryFilter = defaultCategoryFilter

    if Meteor.user()
      if Meteor.user().profile.categoryFilter
        categoryFilter = Meteor.user().profile.categoryFilter

    Session.set('categoryFilter', categoryFilter)

  # Initialize peer with current user's ID
  # Hard code Peer's cloud server API key for now
  @peer = new Peer(Meteor.userId(), {key: 'bpdi6rltdw0qw7b9'})

  # Stores instantiation of call initiated by this user
  @call = null

  # Stored instantiation of call of remote
  @remoteCall = null

  console.log "Meteor startup end"