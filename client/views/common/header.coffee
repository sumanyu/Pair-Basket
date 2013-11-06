Template.header.events =
  'click .ask-question' : (e, selector) ->
    e.preventDefault()

    console.log("asked question")
    # Session.set('firstTimeQuestion', question)
