@getSessionHistory = (profileId) ->
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
      tutors.push session.tutor.name

    if session.tutor.id == profileId
      tutees.push session.tutee.name

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

    sessionHistory = getSessionHistory(profileId)

    user.profile.tutors = sessionHistory.tutors
    user.profile.tutees = sessionHistory.tutees

    console.log user.profile.tutors
    console.log user.profile.tutees

    console.log user.profile
    return user.profile
