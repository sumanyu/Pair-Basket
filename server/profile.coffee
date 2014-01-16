@getClassroomSessionHistory = (profileId) ->
  console.log "getting session history"
  sessionHistory = ClassroomSession.find( 
    {$or: [
      {'tutor.id': profileId},
      {'tutee.id': profileId}
    ]},
    {sort: {_id: -1}}
  )

  tutors = []
  tutees = []

  sessionHistory.forEach (session) ->
    if session.tutee.id == profileId
      tutors.push
        name: session.tutor.name
        userId: session.tutor.id

    if session.tutor.id == profileId
      tutees.push
        name: session.tutee.name
        userId: session.tutee.id

  result = {
    'tutors': tutors
    'tutees': tutees
  }

Meteor.methods

  getUserProfile: (profileId) ->

    console.log "server: getUserProfile"
    # console.log Meteor.userId()
    # console.log profileId

    # find user doc by profileId
    user = Meteor.users.findOne
      _id: profileId

    if not user
      return null

    # attach userId to profile
    user.profile.id = profileId

    # attach tutor/tutee history to profile
    sessionHistory = getClassroomSessionHistory(profileId)

    user.profile.tutors = sessionHistory.tutors
    user.profile.tutees = sessionHistory.tutees

    return user.profile
