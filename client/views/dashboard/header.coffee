Template.header.events =
  'click .ask-question' : (e, selector) ->
    e.preventDefault()

    if Session.get('karma') > 1
      Session.set('askingQuestion?', true)
    else
      Session.set('showNotEnoughKarma?', true)

Template.header.helpers
  userKarma: ->
    Session.get('karma')