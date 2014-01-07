Meteor.startup ->
  console.log "Server is starting!"
  console.log "# of Questions: ", Questions.find().count()
  console.log "# of Feedback: ", Feedback.find().count()

  # Feedback.find().forEach((feedback) ->
  #   console.log feedback
  # )

  # this line should be commented for 'production' setting (don't delete questions)
  dropAll()

  Deps.autorun ->
    console.log "# of session requests: ", SessionRequest.find().count()

Accounts.onCreateUser (options, user) ->
  user.karma = 10
  if options.profile
    user.profile = options.profile

  user.profile.categoryFilter = defaultCategoryFilter
  user.profile.activeSkills = {}

  return user


Meteor.publish "users", ->
  Meteor.users.find
    _id: @userId
  ,
    fields:
      karma: 1
      profile: 1

Meteor.publish 'questions', ->
  Questions.find({})

Meteor.publish 'skills', ->
  Skills.find({})


# I learned that publish functions can't contain if/else logic on a collection
Meteor.publish 'classroomSession', ->
  console.log "Publishing classroom session to: #{@userId}"

  # Return all sessions where dateCreated is within 6 hours of right now and
  # Where if user is tutor, its status is true
  # Else if user is tuteee, its status is true
  # Sort by most recently created and limit query to one
  ClassroomSession.find(
    {$and: [
      {dateCreated: { $gte: new Date( (new Date)*1 - 1000*3600*6 ) }}, 
      {$or: [
        {$and: [{'tutor.status': true}, {'tutor.id': @userId}]},
        {$and: [{'tutee.status': true}, {'tutee.id': @userId}]}
      ]}
    ]},
    {sort: {_id: -1}, limit: 1}
  )

# Subscription for tutees with questions waiting to be answered
Meteor.publish "sessionRequest", (questionId) ->
  console.log "Publish sessionRequest, questionId:", questionId
  SessionRequest.find({questionId: questionId})

# Subscription for tutors with responses for requests sent
Meteor.publish "sessionResponse", (questionId) ->
  console.log "Publish sessionResponse, questionId:", questionId
  SessionResponse.find({questionId: questionId})

alertClassroomSession = (user, classroomSessionId, message, status) ->
  totalMessage = 
    message: message
    user:
      id: user._id
      name: user.profile.name
    type: 'alert'
    dateCreated: new Date

  if ClassroomSession.findOne({'tutor.id': user._id, _id: classroomSessionId})
    ClassroomSession.update {_id: classroomSessionId}, {$set: {'tutor.status': status}, $push: {messages: totalMessage}}
  else if ClassroomSession.findOne({'tutee.id': user._id, _id: classroomSessionId})
    ClassroomSession.update {_id: classroomSessionId}, {$set: {'tutee.status': status}, $push: {messages: totalMessage}}

deleteSharedFilesFromClassroomSession = (classroomSession) ->
  classroomSession.sharedFiles.forEach (file) ->
    Meteor.call 'S3delete', file.path

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

    # Check if has skills
    # need better regex
    if questionData.skills[0] == ''
      throw new Meteor.Error(401, 'Please enter a skill')

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

  # Render ClassroomSession's status 'resolved'
  # Delete shared files on S3 if classroom session is inactive
  endClassroomSession: (classroomSessionId) ->
    message = "#{Meteor.user().profile.name} has ended the session."
    alertClassroomSession Meteor.user(), classroomSessionId, message, false

    inactiveSession = ClassroomSession.findOne({_id: classroomSessionId, 'tutor.status': false, 'tutee.status': false})
    
    # If both users are inactive, remove files from S3
    if inactiveSession
      # Clean up files
      console.log "Cleaning up shared files"
      deleteSharedFilesFromClassroomSession(inactiveSession)

  # Officiall starts classroom session for a user
  enterClassroomSession: (classroomSessionId) ->
    message = "#{Meteor.user().profile.name} has joined the session."
    alertClassroomSession Meteor.user(), classroomSessionId, message, true

  # Use abruptly leaving classroom session
  # Not used right now because it's very hard to track users closing their browsers
  leavingClassroomSession: (classroomSessionId) ->
    console.log 'Calling leavingClassroomSession'
    message = "#{Meteor.user().profile.name} has left the session."
    alertClassroomSession Meteor.user(), classroomSessionId, message, true

  createClassroomSession: (questionId, tutorId) ->
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

    classroomSession =       
      questionId: questionId
      tutor: tutorObject
      tutee: tuteeObject
      messages: []
      sharedFiles: []
      dateCreated: new Date()

    classroomSessionId = ClassroomSession.insert classroomSession, (err, result) ->
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

  # Configure S3 storage
  Meteor.call "S3config", 
    key: 'AKIAJOYKZOSENWR724AQ'
    secret: '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'
    bucket: 'pairbasket-share'
