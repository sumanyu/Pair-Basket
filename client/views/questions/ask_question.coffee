Template.ask_question.events =
  'click input#btnAskQuestion' : (e, selector) ->

    bootbox.alert "Ask a question", ->
      console.log "You pressed start question"
      console.log e
      console.log selector
      