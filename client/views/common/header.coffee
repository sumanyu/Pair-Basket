Template.header.events =
  'click .ask-question' : (e, selector) ->
    e.preventDefault()

    Session.set('askQuestion', true)
    # Session.set('firstTimeQuestion', question)
