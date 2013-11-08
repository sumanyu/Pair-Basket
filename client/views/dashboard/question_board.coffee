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
    Router.go('session')

  'click .decline-button': (e, selector) ->
    Session.set('foundTutor?', false)