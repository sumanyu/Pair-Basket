Template.feedback.events =
  'click #feedback' : (e, selector) ->
    e.preventDefault()
    Session.set('feedbackPopup?', true)

  'click .close-popup-button' : (e, selector) ->
    e.preventDefault()
    Session.set('feedbackPopup?', false)

  'submit' : (e, selector) ->
    e.preventDefault()

    feedbackText = $('textarea.feedback-text').val()

    Meteor.call 'createFeedback', feedbackText, (error, result) ->
      console.log error, result

      if not error
         Session.set('feedbackPopup?', false)

Template.feedback.helpers
  feedbackPopup: ->
    Session.get('feedbackPopup?')