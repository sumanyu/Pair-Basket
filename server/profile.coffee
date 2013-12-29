Meteor.methods
  addOwnedSkill: (skill) ->
    console.log "adding skill"
    console.log skill.name

    ownedSkillData =
      userId: Meteor.userId()
      skill: skill
      academicLevel: "grade 12?"
      dateCreated: new Date()
      display: true

    ownedSkill.insert ownedSkillData, (err, result) ->
      console.log err
      console.log result