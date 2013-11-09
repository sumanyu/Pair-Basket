Template.questionsPage.helpers
  questions: =>
    @Questions.find({}, {sort: {dateCreated: -1}})

  questionsLoaded: ->
    Session.get('hasQuestionsLoaded?')

  askQuestion: ->
    Session.get('askingQuestion?')

  waitingForTutor: ->
    Session.get('waitingForTutor?')

  foundTutor: ->
    Session.get('foundTutor?')

Template.questionsPage.events =
  'click .start-session-button' : (e, selector) ->
    e.preventDefault()

    questionId = Session.get('subscribedQuestion')
    session = Random.id()

    # User Meteor method to notify client
    Meteor.call("createSessionResponse", questionId, session, (err, result) ->
      console.log "SessionRequestCreated"
    )

    Meteor.call("completeSession", questionId, (err, result) ->
      console.log "SessionRequestCreated"
    )    

    Router.go("/session/#{session}")

  'click .decline-button': (e, selector) ->
    Session.set('foundTutor?', false)