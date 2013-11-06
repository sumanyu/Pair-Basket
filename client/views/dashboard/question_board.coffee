Template.question_board.helpers
  questions: =>
    @Questions.find({})

  questionsLoaded: ->
    Session.get('hasQuestionsLoaded?')

  askQuestion: ->
    console.log(Session.get('askQuestion'))
    Session.get('askQuestion')

  waitingForTutor: ->
  	Session.get('waitingForTutor')

Template.question_board.events =
  'click input#btnStartTutoring' : (event, selector) ->
    console.log "You pressed start session"