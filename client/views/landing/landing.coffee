Template.landingPage.events =
  'click input#landingSubmit' : (e, selector) ->
    e.preventDefault()

    question = $('textarea#landingAskQuestion').val()
    Session.set('firstTimeQuestion', question)
    Router.go('dashboard')