Meteor.startup ->
  console.log "Server is starting!"
  console.log "# of Questions: ", Questions.find().count()
  console.log "# of Feedback: ", Feedback.find().count()

  # Feedback.find().forEach((feedback) ->
  #   console.log feedback
  # )

  dropAll()

  Deps.autorun ->
    console.log "# of session requests: ", SessionRequest.find().count()

Accounts.onCreateUser (options, user) ->
  user.karma = 10
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

Meteor.publish 'questions', ->
  Questions.find({})

# I learned that publish functions can't contain if/else logic on a collection
Meteor.publish 'classroomSession', ->
  console.log "Publishing classroom session to: #{@userId}"

  # Unfortunately, we can't query on virtual fields so we can't query on tutoring session

  # Discriminate between tutorId or tuteeId later
  ClassroomSession.find({$or: [{'tutor.id': @userId}, {'tutee.id': @userId}]})

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
      throw new Meteor.Error(401, 'Please enter a category')

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
      throw new Meteor.Error(401, 'Offering more karma than owned')

    questionId = Questions.insert questionData

  cancelOwnedQuestion: (questionId) ->
    if Questions.findOne({_id: questionId, userId: Meteor.userId()})
      SessionRequest.remove({questionId: questionId})
      SessionResponse.remove({questionId: questionId})

      Questions.update(
        {_id: questionId, userId: Meteor.userId()},
        {$set: {status: 'deleted'}}
      )

    else
      throw new Meteor.Error(401, 'User does not own question. Cannot cancel.')

  # createSessionRequest: (questionId) ->
  #   console.log "Creating Session Request"
  #   request = SessionRequest.insert
  #     questionId: questionId
  #     userId: @userId
  #   Random.id()

  # createSessionResponse: (questionId) ->
  #   console.log "Creating Session Response"
  #   classroomSessionId = Random.id()
  #   response = SessionResponse.insert 
  #                 questionId: questionId
  #                 classroomSessionId: classroomSessionId
  #                 userId: @userId
  #   classroomSessionId

  # # Add better validation later
  # cancelSessionResponse: (questionId) ->
  #   SessionResponse.remove({questionId: questionId})

  # Render ClassroomSession's status 'resolved'
  endClassroomSession: (classroomSessionId) ->
    if ClassroomSession.findOne({'tutor.id': @userId, _id: classroomSessionId})
      ClassroomSession.update {_id: classroomSessionId}, {$set: {'tutor.status': false}}
    else if ClassroomSession.findOne({'tutee.id': @userId, _id: classroomSessionId})
      ClassroomSession.update {_id: classroomSessionId}, {$set: {'tutee.status': false}}

    # Let others know user has left
    # Event emitter?

  startClassroomSession: (questionId, tutorId) ->
    # Remove sessionRequest and sessionResponse and question from question
    console.log "Start session"
    tuteeId = @userId

    karmaOffered = Questions.findOne({'_id': questionId}).karmaOffered

    # console.log questionId
    # console.log karmaOffered

    # learner lose karma, teacher gain karma
    Meteor.users.update(
      {'_id': tuteeId},
      { $inc: {'karma': -1*karmaOffered} })
    
    Meteor.users.update(
      {'_id': tutorId},
      { $inc: {'karma': karmaOffered} })

    SessionRequest.remove({questionId: questionId})

    Questions.update(
      {_id: questionId},
      {$set: {status: 'resolved'}}
    )

    tutor = Meteor.users.findOne({_id: tutorId})
    tutorObject = 
      id: tutorId
      name: tutor.profile.name
      school: tutor.profile.school
      status: true

    tutee = Meteor.user()
    tuteeObject = 
      id: tuteeId
      name: tutee.profile.name
      school: tutee.profile.school
      status: true

    console.log tutor
    console.log tutee

    obj =       
      questionId: questionId
      tutor: tutorObject
      tutee: tuteeObject
      messages: []

    # Add tutor name
    classroomSessionId = ClassroomSession.insert obj, (err, result) ->
      console.log "Inserting classroom session"
      if err
        console.log "Error"
        console.log err
      else
        console.log "Result"
        console.log result

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