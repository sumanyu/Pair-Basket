Template.feedback.events =
  'click #feedback' : (e, selector) ->
    e.preventDefault()
    Session.set('feedbackPopup?', true)

  'click .close-popup-button' : (e, selector) ->
    e.preventDefault()
    Session.set('feedbackPopup?', false)

Template.feedback.helpers
  feedbackPopup: ->
    Session.get('feedbackPopup?')