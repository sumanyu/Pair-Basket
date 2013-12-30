Template.profilePage.helpers
  tutors: ->
    Meteor.call "getSessionHistory", (error, result) ->
      console.log error
      console.log result

      Session.set("tutors", result.tutors)

    Session.get("tutors")

  tutees: ->
    Meteor.call "getSessionHistory", (error, result) ->
      console.log error
      console.log result

      Session.set("tutees", result.tutees)

    Session.get("tutees")

  # ownedSkills: ->
  #   ownedSkills = OwnedSkills.find({})

  # this is really frustrating
  # skillName: (skillId) ->
  #   Skills.findOne({_id: skillId}).name
