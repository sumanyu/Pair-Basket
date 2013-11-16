Template.questionsPage.helpers
  ownedQuestions: =>
    @OwnedQuestions.find({})

  otherQuestions: =>
    @OtherQuestions.find({})

  questionsLoaded: ->
    Session.get('hasQuestionsLoaded?')

  askQuestion: ->
    Session.get('askingQuestion?')

  foundTutor: ->
    Session.get('foundTutor?')

  notEnoughKarma: ->
    Session.get('showNotEnoughKarma?')

Template.questionsPage.events =
  'click .start-session-button' : (e, selector) ->
    e.preventDefault()

    questionId = Session.get('subscribedQuestion')
    session = Random.id()

    # User Meteor method to notify client
    Meteor.call("createSessionResponse", questionId, session, Session.get('userName'), (err, result) ->
      console.log "SessionRequestCreated"
    )

    Meteor.call("startSession", questionId, (err, result) ->
      console.log "startSession"
    )    

    Router.go("/session/#{session}")

  'click .decline-button': (e, selector) ->
    Session.set('foundTutor?', false)

  'click .back-to-dashboard-button': (e, selector) ->
    Session.set('showNotEnoughKarma?', false)    