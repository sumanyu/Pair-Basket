Template.profilePage.helpers
  tutors: ->
    Meteor.call "getSessionHistory", (error, result) ->
      console.log error
      console.log result

      Session.set("tutors", result)

    tutorSessions = Session.get("tutors")
