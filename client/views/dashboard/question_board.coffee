Template.question_board.helpers
  questions: =>
    @Questions.find(
      {},
      {sort: {dateCreated: -1}}
    )

  questionsLoaded: ->
    Session.get('hasQuestionsLoaded?')

  askQuestion: ->
    console.log(Session.get('askQuestion'))
    Session.get('askQuestion')

  waitingForTutor: ->
    Session.get('waitingForTutor')

  foundTutor: ->
    Session.get('foundTutor')

Template.question_board.events =
  'click input#btnStartTutoring' : (event, selector) ->
    console.log "You pressed start session"

  'click .start-session-button' : (e, selector) ->
      e.preventDefault()
      console.log "session"
      Router.go('session')