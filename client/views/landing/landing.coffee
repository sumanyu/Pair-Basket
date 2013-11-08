Template.landingPage.events =
  'click input#landingSubmit' : (e, selector) ->
    e.preventDefault()

    question = $('textarea#landingAskQuestion').val()

    Session.set('questionFromLandingPrompt', question)
    Session.set('askingQuestion?', true)

    Router.go('dashboard')