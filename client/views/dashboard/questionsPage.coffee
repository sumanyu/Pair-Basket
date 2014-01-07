Template.questionsPage.helpers
  ownedQuestions: =>
    Questions.find(
      {
        userId: Meteor.userId(),
        status: 'waiting'
      },
      {sort: {dateCreated: -1}})

  recommendedQuestions: =>
    # TODO: improve/integrate recommended and other questions
    categoryFilter = Session.get('categoryFilter')
    # console.log categoryFilter

    activeCategories = []
    for category, active of categoryFilter
      if active
        activeCategories.push(category)
    # console.log activeCategories

    questions = Questions.find(
      {
        userId: { $ne: Meteor.userId() },
        status: 'waiting',
        category: { $in: activeCategories }
      },
      {sort: {dateCreated: -1}})

    recommendedQuestions = []

    questions.forEach (question) ->
      question.skills.forEach (skill) ->
        # recommend this question if:
          # any question-skills match user-active-skills
        if Meteor.user().profile.activeSkills
          if Meteor.user().profile.activeSkills[skill]
            recommendedQuestions.push(question)
            return

    return recommendedQuestions

  otherQuestions: =>
    categoryFilter = Session.get('categoryFilter')
    # console.log categoryFilter

    activeCategories = []
    for category, active of categoryFilter
      if active
        activeCategories.push(category)
    # console.log activeCategories

    questions = Questions.find(
      {
        userId: { $ne: Meteor.userId() },
        status: 'waiting',
        category: { $in: activeCategories }
      },
      {sort: {dateCreated: -1}})

    otherQuestions = []

    # TODO: fix hack
    questions.forEach (question) ->
      skillsNotFound = true

      question.skills.forEach (skill) ->
        # recommend this question if:
          # any question-skills match user-active-skills
        if Meteor.user().profile.activeSkills
          if Meteor.user().profile.activeSkills[skill]
            skillsNotFound = false

      if skillsNotFound
        otherQuestions.push(question)

    return otherQuestions

  resolvedQuestions: =>
    categoryFilter = Session.get('categoryFilter')
    # console.log categoryFilter

    activeCategories = []
    for category, active of categoryFilter
      if active
        activeCategories.push(category)
    # console.log activeCategories

    Questions.find(
      {
        status: 'resolved',
        category: { $in: activeCategories }
      },
      {sort: {dateCreated: -1}})

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

    questionId = Session.get('subscribedQuestion')
    tutorId = Session.get('subscribedResponse')

    Meteor.call("createClassroomSession", questionId, tutorId, (err, classroomSessionId) ->
      console.log "createClassroomSession"

      if err
        console.log err
      else
        console.log Session.get('subscribedResponse')

        ClassroomStream.emit "response:#{Session.get('subscribedResponse')}", classroomSessionId
        Router.go("/session/#{classroomSessionId}")
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

    clickedCategory = e.target.id
    state = e.target.className.split(" ")[1] # active, inactive
    categoryFilter = Session.get('categoryFilter')

    # toggle active/inactive
    categoryFilter[clickedCategory] = !(state == 'active')

    # update categoryFilters: user-profile, session 
    Meteor.users.update(
      {_id:Meteor.user()._id},
      {$set: {"profile.categoryFilter": categoryFilter}})

    Session.set('categoryFilter', categoryFilter)
