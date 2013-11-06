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
    tags = $('textarea#question-category').value
    title = $('textarea#question-title').value
    text = $('textarea#question-text').value
    karma_offered = $('textarea#karma-offered').value

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