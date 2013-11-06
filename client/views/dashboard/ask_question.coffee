Template.ask_question.events =
  'click input#btnAskQuestion' : (e, selector) ->
    console.log "You pressed start question"
    console.log e
    console.log selector

  'click .overlay' : (e, selector) ->
    Session.set('askQuestion', false)

  'click input#question-submit' : (e, selector) ->
    e.preventDefault()

    console.log("clicked question submit")
    tags = $('textarea#question-category').val()
    title = $('textarea#question-title').val()
    text = $('textarea#question-text').val()
    karma_offered = $('textarea#karma-offered').val()

    console.log tags
    console.log title
    console.log text
    console.log karma_offered


    question = 
        title: text
        userId: '1'
        category: title
        tags: [tags]
        karmaOffered: parseInt(karma_offered)
        dateCreated: new Date()
        dateModified: new Date()
        status: "Active"

    console.log(question)
    Questions.insert question

    Session.set('askQuestion', false)
    Session.set('waitingForTutor', true)

    wait_for_tutor = () ->
        setTimeout (->
        found_tutor
        ), 4000

    found_tutor = () ->
        Session.set('waitingForTutor', false)
        Session.set('foundTutor', true)

    wait_for_tutor()