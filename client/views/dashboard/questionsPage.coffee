Template.questionsPage.helpers
  ownedQuestions: =>
    Questions.find(
      {
        userId: Meteor.userId(),
        status: 'waiting'
      },
      {sort: {dateCreated: -1}})

  otherQuestions: =>
    Questions.find(
      {
        userId: { $ne: Meteor.userId() },
        status: 'waiting'
      },
      {sort: {dateCreated: -1}})

  questionsLoaded: ->
    Session.get('hasQuestionsLoaded?')

  askQuestion: ->
    Session.get('askingQuestion?')

  foundTutor: ->
    Session.get('foundTutor?')

  notEnoughKarma: ->
    Session.get('showNotEnoughKarma?')

Template.questionsPage.events =
  'click .start-session-button' : (e, selector) ->
    e.preventDefault()

    request = SessionRequest.findOne({})
    questionId = request.questionId
    tutorId = request.userId

    session = Random.id()

    # User Meteor method to notify client
    Meteor.call("createSessionResponse", questionId, session, (err, result) ->
      console.log "SessionResponseCreated"

      if err
        console.log err
      else
        Meteor.call("startSession", questionId, session, tutorId, (err, result) ->
          console.log "startSession"

          if err
            console.log err
          else
            console.log result

            # Subscribe to tutoring session
            Meteor.subscribe 'tutoringSession', session, ->
              console.log @
              Router.go("/session/#{session}")
        )
    )

  'click .decline-button': (e, selector) ->
    Session.set('foundTutor?', false)

  'click .back-to-dashboard-button': (e, selector) ->
    Session.set('showNotEnoughKarma?', false)    