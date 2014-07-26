createAccountHelpingOthers = (parentElement) ->
  dataDict = 
    name : "#{parentElement} .name"
    school : "#{parentElement} .school"
    email : "#{parentElement} input[type=email]"
    password : "#{parentElement} input[type=password]"

  onValidInput dataDict, (sanitizedDataDict) ->
    data = _.pick(sanitizedDataDict, 'name', 'school', 'email', 'password')

    profile =
      'name': data['name']
      'school': data['school']

    # Create meteor account, on client will log-in upon successful completion
    Accounts.createUser {email: data['email'], password: data['password'], profile: profile}, (err) ->
      if err
        console.log err
      else
        # Success, account was created
        Router.go('dashboard')

createAccountWhenAskingQuestion = (parentElement) ->
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
    Accounts.createUser {email: data['email'], password: data['password'], profile: profile}, (err) ->
      if err
        console.log err
      else
        # Success, account was created
        Session.set('questionFromLandingPrompt', data['question'])
        Session.set('askingQuestion?', true)
        Router.go('dashboard')

Template.landingCallToActionTop.helpers
  helpOthers: ->
    Session.get('topCTAHelpOthers?')

  askQuestion: ->
    Session.get('topCTAAskQuestion?')

  showBoth: ->
    Session.get('topCTAShowBoth?')

Template.landingCallToActionTop.events =
  'click .ask-question-btn': (e, s) ->
    Session.set('topCTAAskQuestion?', true)

    Session.set('topCTAHelpOthers?', false)
    Session.set('topCTAShowBoth?', false)

  'click .help-others-btn': (e, s) ->
    Session.set('topCTAHelpOthers?', true)

    Session.set('topCTAAskQuestion?', false)
    Session.set('topCTAShowBoth?', false)

Template.landingHelpOthersTop.rendered = ->
  focusText($('.help-others-wrapper .name'))

Template.landingHelpOthersTop.events =
  'submit': (e, s) ->
    e.preventDefault()

    parentElement = '.help-others-wrapper'
    createAccountHelpingOthers(parentElement)

Template.landingAskQuestionTop.rendered = ->
  focusText($('.ask-question-wrapper textarea'))

Template.landingAskQuestionTop.events =
  'submit': (e, s) ->
    e.preventDefault()

    parentElement = '.ask-question-wrapper'
    createAccountWhenAskingQuestion(parentElement)

#


Template.landingCallToActionBottom.helpers
  helpOthers: ->
    Session.get('bottomCTAHelpOthers?')

  askQuestion: ->
    Session.get('bottomCTAAskQuestion?')

  showBoth: ->
    Session.get('bottomCTAShowBoth?')

Template.landingCallToActionBottom.events =
  'click .ask-question-btn': (e, s) ->
    Session.set('bottomCTAAskQuestion?', true)

    Session.set('bottomCTAHelpOthers?', false)
    Session.set('bottomCTAShowBoth?', false)

  'click .help-others-btn': (e, s) ->
    Session.set('bottomCTAHelpOthers?', true)

    Session.set('bottomCTAAskQuestion?', false)
    Session.set('bottomCTAShowBoth?', false)

Template.landingHelpOthersBottom.rendered = ->
  focusText($('.help-others-wrapper .name'))

Template.landingHelpOthersBottom.events =
  'submit': (e, s) ->
    e.preventDefault()

    parentElement = '.help-others-wrapper'
    createAccountHelpingOthers(parentElement)

Template.landingAskQuestionBottom.rendered = ->
  focusText($('.ask-question-wrapper textarea'))

Template.landingAskQuestionBottom.events =
  'submit': (e, s) ->
    e.preventDefault()

    parentElement = '.ask-question-wrapper'
    createAccountWhenAskingQuestion(parentElement)