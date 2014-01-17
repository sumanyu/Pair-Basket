Template.landingCallToActionTop.helpers
  helpOthers: ->
    Session.get('helpOthers?')

  askQuestion: ->
    Session.get('askQuestion?')

  showBoth: ->
    Session.get('showBoth?')

logSession = ->
  ['askQuestion?', 'helpOthers?', 'showBoth?'].forEach (vars) ->
    console.log vars, Session.get(vars)

Template.landingCallToActionTop.events =
  'click .ask-question-btn': (e, s) ->
    Session.set('askQuestion?', true)

    Session.set('helpOthers?', false)
    Session.set('showBoth?', false)

  'click .help-others-btn': (e, s) ->
    Session.set('helpOthers?', true)

    Session.set('askQuestion?', false)
    Session.set('showBoth?', false)

onValidInput = (dataDict, func) ->
  # Clean input
  sanitizedDataDict = {}
  _.keys(dataDict).forEach (key) ->
    sanitizedDataDict[key] = $("#{dataDict[key]}").val().trim()

  console.log dataDict
  console.log sanitizedDataDict

  # Validate inputs - for now just check if all inputs were entered
  if areElementsNonEmpty(_.values(sanitizedDataDict))
    func(sanitizedDataDict)
  else
    # Throw some message
    console.log "invalid input"

Template.landingHelpOthersTop.rendered = ->
  focusText($('.help-others-wrapper .name'))

Template.landingHelpOthersTop.events =
  'submit': (e, s) ->
    e.preventDefault()

    # Clean input
    name = $('.help-others-wrapper .name').val().trim()
    school = $('.help-others-wrapper .school').val().trim()
    email = $('.help-others-wrapper input[type=email]').val().trim()
    password = $('.help-others-wrapper input[type=password]').val().trim()

    # Validate inputs - for now just check if all inputs were entered
    isInputValid = areElementsNonEmpty([email, password, name, school])

    if isInputValid

      profile =
        'name': name
        'school': school

      # Create meteor account, on client will log-in upon successful completion
      Accounts.createUser {email: email, password: password, profile: profile}, (err) ->
        if err
          console.log err
        else
          # Success, account was created
          Router.go('dashboard')
    else
      # Throw some message
      console.log "invalid input"

Template.landingAskQuestionTop.rendered = ->
  focusText($('.ask-question-wrapper textarea'))

Template.landingAskQuestionTop.events =
  'submit': (e, s) ->
    e.preventDefault()

    parentElement = '.ask-question-wrapper'

    dataDict = 
      name : "#{parentElement} .name"
      school : "#{parentElement} .school"
      email : "#{parentElement} input[type=email]"
      password : "#{parentElement} input[type=password]"
      question : "#{parentElement} textarea.question"

    onValidInput dataDict, (sanitizedDataDict) ->
      data = _.pick(sanitizedDataDict, 'name', 'school', 'email', 'password', 'question')

      profile =
        'name': data['name']
        'school': data['school']

      # Create meteor account, on client will log-in upon successful completion
      Accounts.createUser {email: data['email'], password: data['password'], profile: data['profile']}, (err) ->
        if err
          console.log err
        else
          # Success, account was created
          Session.set('questionFromLandingPrompt', data['question'])
          Session.set('askingQuestion?', true)
          Router.go('dashboard')