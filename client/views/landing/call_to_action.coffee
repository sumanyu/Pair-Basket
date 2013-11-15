sendQuestion = ->
  email = $('input[type=email]').val()
  password = $('input[type=password]').val()
  question = $('textarea.question').val()

  console.log email, password, question

  # Clean input

  # Validate email

  # Validate password

  # Create meteor account

  # Log the user in

  Session.set('questionFromLandingPrompt', question)
  Session.set('askingQuestion?', true)

  # Router.go('dashboard')

Template.landingCallToAction.helpers
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

Template.landingCallToAction.events =
  'click .ask-question-btn': (e, s) ->
    Session.set('askQuestion?', true)

    Session.set('helpOthers?', false)
    Session.set('showBoth?', false)

    logSession()

  'click .help-others-btn': (e, s) ->
    Session.set('helpOthers?', true)

    Session.set('askQuestion?', false)
    Session.set('showBoth?', false)

    logSession()

  'submit' : (e, s) ->
    console.log 'landingCallToAction'

  # 'click input#landingSubmit' : (e, selector) ->
  #   e.preventDefault()
  #   sendQuestion()

  # 'keyup #landingAskQuestion': (e, t) ->
  #   e.preventDefault()

  #   # on Enter
  #   if e.which is 13
  #     sendQuestion()

Template.landingHelpOthers.events =
  'submit': (e, s) ->
    # sendQuestion()

Template.landingAskQuestion.events =
  'submit .ask-question-form-button': (e, s) ->

    console.log 'submit'

    email = $('input[type=email]').val()
    password = $('input[type=password]').val()
    question = $('textarea.question').val()

    console.log email, password, question