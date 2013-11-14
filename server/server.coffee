populateQuestions = ->
  if Meteor.isServer and Questions.find().count() is 0
  # if Questions.find().count() is 0
    questions = [
      title: "Linguistic Anthropology"
      userId: '1'
      question: "What are John Wesley Powell's contributions to the modern view of languages?"
      tags: [
        "John Wesley Powell",
        "Philosophy"
      ]
      karmaOffered: 50
      dateCreated: new Date()
      dateModified: new Date()
      status: "Active"
    ,
      title: "atan vs. atan2 in C++"
      userId: '1'
      question: 'What is the difference between atan and atan2 functions in the cmath library in C++?'
      tags: [
        "C++"
      ,
        "Programming"
      ]
      karmaOffered: 20
      dateCreated: new Date()
      dateModified: new Date()
      status: "Active"
    ,
      title: "Epsilon-N Proof"
      userId: '1'
      question: 'How do we prove that as n -> inf, (3n+1)/(2n+1) -> 3/2 using the formal definition of a limit?'
      tags: [
        "Calculus"
      ,
        "Delta Epsilon proofs"
      ]
      karmaOffered: 80
      dateCreated: new Date()
      dateModified: new Date()
      status: "Active"
    ]

    for question in questions
      Questions.insert question
      # console.log question

dropAll = ->
  SessionRequest.remove({})
  Questions.remove({})
  populateQuestions()

Meteor.startup ->
  console.log "Server is starting!"
  console.log "# of Questions: ", Questions.find().count()
  dropAll()

  Deps.autorun ->
    console.log "# of session requests: ", SessionRequest.find().count()

Meteor.publish "questions", ->
  Questions.find({})

# Subscription for tutees with questions waiting to be answered
Meteor.publish "sessionRequest", (questionId) ->
  console.log "Publish sessionRequest, questionId:", questionId
  SessionRequest.find({questionId: questionId})

# Subscription for tutors with responses for requests sent
Meteor.publish "sessionResponse", (questionId) ->
  console.log "Publish sessionResponse, questionId:", questionId
  SessionResponse.find({questionId: questionId})

Meteor.methods
  createNewQuestion: (questionData) ->
    currentUser = Meteor.user()

    console.log currentUser

    # Check if logged in
    throw new Meteor.Error(401, 'You need to log in to post new questions') if not currentUser

    # Test Collection2

    console.log questionData

    Questions.insert questionData, (error, result) ->
      console.log result
      console.log error

    # Check if has question title
    # if not questionData.title
    #   throw new Meteor.Error(401, 'You need to log in to post new questions')      

    # Check if has tags

    # Check if has description

    # Check if offers karma

    # Check if user has enough karma


  createSessionRequest: (questionId, userName) ->
    console.log "Creating Session Request"
    requestId = SessionRequest.insert {questionId: questionId, userName: userName}

  createSessionResponse: (questionId, sessionId, userName) ->
    console.log "Creating Session Response"
    responseId = SessionResponse.insert 
                  questionId: questionId
                  sessionId: sessionId
                  userName: userName

  completeSession: (questionId) ->
    # Remove sessionRequest and sessionResponse and question from question
    console.log "Complete session"

    # console.log SessionRequest.find().count()
    # console.log SessionResponse.find().count()
    # console.log Questions.find({}).count()

    SessionRequest.remove({questionId: questionId})
    SessionResponse.remove({questionId: questionId})
    Questions.remove({_id: questionId})

    # console.log SessionRequest.find().count()
    # console.log SessionResponse.find().count()
    # console.log Questions.find({}).count()