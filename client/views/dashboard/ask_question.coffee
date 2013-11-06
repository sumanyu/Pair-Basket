Template.ask_question.events =
  'click input#btnAskQuestion' : (e, selector) ->
    console.log "You pressed start question"
    console.log e
    console.log selector

  'click .overlay' : (e, selector) ->
    Session.set('askQuestion', false)
