sendQuestion = ->
  question = $('textarea#landingAskQuestion').val()

  Session.set('questionFromLandingPrompt', question)
  Session.set('askingQuestion?', true)

  Router.go('dashboard')  

Template.callToAction.events =
  'click input#landingSubmit' : (e, selector) ->
    e.preventDefault()
    sendQuestion()

  'keyup #landingAskQuestion': (e, t) ->
    e.preventDefault()

    # on Enter
    if e.which is 13
      sendQuestion()