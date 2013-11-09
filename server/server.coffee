populateQuestions = ->
  # if Meteor.isServer and Questions.find().count() is 0
  if Questions.find().count() is 0
    questions = [
      title: "How do you get the limit for 0/0?"
      userId: '1'
      text: "I tried doing xy but I'm not sure if I can do xyz and abcd as well"
      tags: [
        "Calculus"
      ,
        "Grade 12"
      ]
      karmaOffered: 30
      dateCreated: new Date()
      dateModified: new Date()
      status: "Active"
    ,
      title: "What is photosynthesis?"
      userId: '1'
      text: 'Some text, Some text, Some text,'
      tags: [
        "Plants"
      ,
        "Grade 5"
      ]
      karmaOffered: 50
      dateCreated: new Date()
      dateModified: new Date()
      status: "Active"
    ,
      title: "In elastic collisions, why is momentum conserved?"
      userId: '1'
      text: 'Some text, Some text, Some text, Some text, Some text, Some text, Some text,'
      tags: [
        "Kinematics"
      ,
        "Energy"
      ,
        "Grade 10"
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