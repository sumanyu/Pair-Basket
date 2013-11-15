sendQuestion = ->
  question = $('textarea#landingAskQuestion').val()

  Session.set('questionFromLandingPrompt', question)
  Session.set('askingQuestion?', true)

  Router.go('dashboard')  

Template.callToAction.helpers
  helpOthers: ->
    Session.get('helpOthers?')

  askQuestion: ->
    Session.get('askQuestion?')

  showBoth: ->
    console.log 'showBoth?', Session.get('showBoth?')
    Session.get('showBoth?')

  # showHelpOthersAndAskQuestion: ->
  #   not (Session.get('helpOthers?') and Session.get('askQuestion?'))

logSession = ->
  ['askQuestion?', 'helpOthers?', 'showBoth?'].forEach (vars) ->
    console.log vars, Session.get(vars)

Template.callToAction.events =
  'click .ask-question': (e, s) ->
    Session.set('askQuestion?', true)

    Session.set('helpOthers?', false)
    Session.set('showBoth?', false)

    logSession()

  'click .help-others': (e, s) ->
    Session.set('helpOthers?', true)

    Session.set('askQuestion?', false)
    Session.set('showBoth?', false)

    logSession()

  # 'click input#landingSubmit' : (e, selector) ->
  #   e.preventDefault()
  #   sendQuestion()

  # 'keyup #landingAskQuestion': (e, t) ->
  #   e.preventDefault()

  #   # on Enter
  #   if e.which is 13
  #     sendQuestion()