Handlebars.registerHelper(
  "underscoreToSpace",
  (string) ->
    string.split("_").join(" ")
);

# TODO: put this array somewhere. it is copied in server.coffee
Handlebars.registerHelper(
  "allCategory",
  () ->
    [
      'math',
      'science',
      'english',
      'social_science',
      'computer',
      'business',
      'foreign_language',
    ]
);

Template.questionsPage.helpers
  ownedQuestions: =>
    Questions.find(
      {
        userId: Meteor.userId(),
        status: 'waiting'
      },
      {sort: {dateCreated: -1}})

  otherQuestions: =>
    categoryFilter = Session.get('categoryFilter')
    # console.log categoryFilter

    activeCategories = []
    for category, active of categoryFilter
      if active
        activeCategories.push(category)
    # console.log activeCategories

    Questions.find(
      {
        userId: { $ne: Meteor.userId() },
        status: 'waiting',
        category: { $in: activeCategories }
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

  isCategoryActive: (category) ->
    categoryFilter = Session.get('categoryFilter')
    categoryFilter[category]

Template.questionsPage.events =
  'click .start-session-button' : (e, selector) ->
    e.preventDefault()

    request = SessionRequest.findOne({})
    questionId = request.questionId
    tutorId = request.userId

    # User Meteor method to notify client
    Meteor.call("createSessionResponse", questionId, (err, session) ->
      console.log "SessionResponseCreated"

      if err
        console.log err
      else
        Meteor.call("startSession", questionId, session, tutorId, (err, tutoringSessionId) ->
          console.log "startSession"

          if err
            console.log err
          else
            console.log tutoringSessionId

            ClassroomStream.emit "response:#{Session.get('subscribedResponse')}", session

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

  'click .category': (e, selector) ->
    ### 
      when a category filter is clicked, toggle between active/inactive
      update session variable category filters, which reactively updates question list
    ###

    category = e.target.id
    state = e.target.className.split(" ")[1] # active, inactive
    categoryFilter = Session.get('categoryFilter')

    # toggle active/inactive
    categoryFilter[category] = !(state == 'active')

    Session.set('categoryFilter', categoryFilter)
