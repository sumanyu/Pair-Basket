Meteor.methods
  getSessionHistory: () ->
    console.log "getting session history"
    sessionHistory = ClassroomSession.find( 
      {$or: [
        {'tutor.id': @userId},
        {'tutee.id': @userId}
      ]},
      {sort: {_id: -1}}
    )

    tutors = []
    tutees = []

    console.log "tutors"
    sessionHistory.forEach (session) ->
      if session.tutee.id == Meteor.userId()
        tutors.push session.tutor.name

      if session.tutor.id == Meteor.userId()
        tutees.push session.tutee.name

    result = {
      'tutors': tutors
      'tutees': tutees
    }

  addOwnedSkill: (skillId) ->
    console.log "adding skill"

    ownedSkillData =
      userId: Meteor.userId()
      skillId: skillId
      academicLevel: "grade 12?"
      dateCreated: new Date()
      display: true

    OwnedSkills.insert ownedSkillData, (err, result) ->
      console.log err
      console.log result

    console.log OwnedSkills.find().count()