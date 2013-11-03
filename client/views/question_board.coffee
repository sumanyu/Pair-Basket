Template.question_board.helpers
	questions: ->
		"Welcome to edu-hack."

Template.question_board.events =
  'click input#btnStartTutoring' : (event, selector) ->
    console.log "You pressed start session"