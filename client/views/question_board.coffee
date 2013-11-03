Template.question_board.helpers
	questions: ->
		Questions.find({})

Template.question_board.events =
  'click input#btnStartTutoring' : (event, selector) ->
    console.log "You pressed start session"