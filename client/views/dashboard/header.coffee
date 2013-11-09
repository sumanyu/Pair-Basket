Template.header.events =
  'click .ask-question' : (e, selector) ->
    e.preventDefault()

    Session.set('askingQuestion?', true)