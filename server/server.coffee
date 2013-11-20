@allCategory = [
  'math',
  'science',
  'english',
  'social_science',
  'computer',
  'business',
  'foreign_language',
]

populateQuestions = ->
  if Meteor.isServer and Questions.find().count() is 0
  # if Questions.find().count() is 0
    questions = [
      category: "english"
      userId: '1'
      questionText: "How do you structure an essay to be creative but effective?"
      tags: [
        "essay",
        "writing"]
      karmaOffered: 50
      dateCreated: new Date()
      dateModified: new Date()
      status: "waiting"
    ,
      category: "computer"
      userId: '1'
      questionText: 'What is the difference between atan and atan2 functions in the cmath library in C++?'
      tags: [
        "c++",
        "programming"]
      karmaOffered: 20
      dateCreated: new Date()
      dateModified: new Date()
      status: "waiting"
    ,
      category: "math"
      userId: '1'
      questionText: 'How do we prove that as n -> inf, (3n+1)/(2n+1) -> 3/2 using the formal definition of a limit?'
      tags: [
        "calculus",
        "delta_epsilon_proof"]
      karmaOffered: 80
      dateCreated: new Date()
      dateModified: new Date()
      status: "waiting"
    ,
      category: "science"
      userId: '1'
      questionText: 'How do you draw a free body diagram with deformable solids?'
      tags: [
        "deformable_solids",
        "physics"]
      karmaOffered: 45
      dateCreated: new Date()
      dateModified: new Date()
      status: "waiting"
    ,
      category: "science"
      userId: '1'
      questionText: 'Why is citric acid a key part of the Krebs Cycle?'
      tags: [
        "biology",
        "metabolism"]
      karmaOffered: 57
      dateCreated: new Date()
      dateModified: new Date()
      status: "waiting"
    ,
      category: "business"
      userId: '1'
      questionText: 'How do banks create value by lending money they do not own?'
      tags: [
        "finance",
        "multiplier_effect"]
      karmaOffered: 92
      dateCreated: new Date()
      dateModified: new Date()
      status: "waiting"
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
  console.log "# of Feedback: ", Feedback.find().count()

  dropAll()

  Deps.autorun ->
    console.log "# of session requests: ", SessionRequest.find().count()

Accounts.onCreateUser (options, user) ->
  user.karma = 100
  if options.profile
    user.profile = options.profile
  # We still want the default hook's 'profile' behavior.
  # if (options.profile)
  #   user.profile = options.profile;
  return user


# TODO
# can users manually edit karma with this implementation?
# would this fix it?:
# Meteor.users.deny({update: function () { return true; }});

Meteor.publish "users", ->
  Meteor.users.find
    _id: @userId
  ,
    fields:
      karma: 1
      profile: 1

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

    # console.log currentUser

    # Check if logged in
    if not currentUser
      throw new Meteor.Error(401, 'Please log in to post new questions')

    # Test Collection2

    questionData['userId'] = currentUser['_id']
    questionData['status'] = 'waiting'
    questionData['dateCreated'] = new Date()
    questionData['dateModified'] = new Date()
    # console.log questionData

    # Check if has category
    if questionData.category not in allCategory
      throw new Meteor.Error(401, 'Please select a category')

    # Check if has tags
    # need better regex
    if questionData.tags[0] == ''
      throw new Meteor.Error(401, 'Please enter a tag')

    # Check if has question
    if not questionData.questionText
      throw new Meteor.Error(401, 'Please enter a question')

    # Check if offers karma
    if not questionData.karmaOffered
      throw new Meteor.Error(401, 'Please enter karma offered')

    # Check if user has enough karma
    if Meteor.user().karma < questionData.karmaOffered
      throw new Meteor.Error(401, 'Karma offered greater than karma owned')

    Questions.insert questionData, (error, result) ->
      console.log result
      console.log error

  cancelOwnedQuestion: (questionId) ->
    if Meteor.userId() == Questions.findOne({_id: questionId}).userId
      SessionRequest.remove({questionId: questionId})

      Questions.update(
        {_id: questionId},
        {$set: {status: 'deleted'}}
      )

    else
      throw new Meteor.Error(401, 'User does not own question. Cannot cancel.')

  createSessionRequest: (questionId, user) ->
    console.log "Creating Session Request"
    requestId = SessionRequest.insert
      questionId: questionId
      user: user

  createSessionResponse: (questionId, sessionId, userName) ->
    console.log "Creating Session Response"
    responseId = SessionResponse.insert 
                  questionId: questionId
                  sessionId: sessionId
                  userName: userName

  startSession: (questionId) ->
    # Remove sessionRequest and sessionResponse and question from question
    console.log "Complete session"
    # console.log SessionRequest
    # console.log SessionRequest.findOne()

    tutorId = SessionRequest.findOne().user['_id']
    # console.log tutorId 
    # console.log SessionRequest.find().count()
    # console.log SessionResponse.find().count()
    # console.log Questions.find({}).count()

    karmaOffered = Questions.findOne({'_id': questionId}).karmaOffered

    # console.log questionId
    # console.log karmaOffered

    # learner lose karma, teacher gain karma
    Meteor.users.update(
      {'_id': Meteor.userId()},
      { $inc: {'karma': -1*karmaOffered} })
    
    Meteor.users.update(
      {'_id': tutorId},
      { $inc: {'karma': karmaOffered} })

    SessionRequest.remove({questionId: questionId})
    SessionResponse.remove({questionId: questionId})

    Questions.update(
      {_id: questionId},
      {$set: {status: 'resolved'}}
    )

    # console.log SessionRequest.find().count()
    # console.log SessionResponse.find().count()
    # console.log Questions.find({}).count()

  createFeedback: (feedbackText) ->
    if not Meteor.user()
      throw new Meteor.Error(401, 'Please log in to give feedback')

    feedbackData =
      'userId': Meteor.userId()
      'feedbackText': feedbackText
      'dateCreated': new Date()

    Feedback.insert feedbackData, (error, result) ->
      console.log result
      console.log error