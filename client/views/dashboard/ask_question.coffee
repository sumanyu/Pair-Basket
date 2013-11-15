Template.ask_question.helpers
  getFirstQuestion: =>
    Session.get('questionFromLandingPrompt') if Session.get('questionFromLandingPrompt')

  validForm: ->
    parseInt($('input#karma-offered').val()) <= Session.get('karma')

Template.ask_question.rendered = ->
  selector = $('.questionForm').find("#question-tags") 
  focusText(selector)

Template.ask_question.maxKarma = ->
  Session.get('karma')

Template.ask_question.events =
  'click .overlay' : (e, selector) ->
    Session.set('questionFromLandingPrompt', null)
    Session.set('askingQuestion?', false)

  'submit input#question-submit' : (e, selector) ->
    e.preventDefault()

    stringTags = $('input#question-tags').val()
    tagsList = stringTags.split(",")

    tags = if tagsList.length is 0
            [stringTags].map (tag) -> tag.trim()
          else
            tagsList.map (tag) -> tag.trim()

    title = $('input#question-title').val()
    question = $('textarea#question-text').val()
    karmaOffered = parseInt($('input#karma-offered').val())

    question = 
      title: title
      userId: '1'
      question: question
      tags: tags
      karmaOffered: karmaOffered
      dateCreated: new Date()
      dateModified: new Date()
      status: "Active"

    Meteor.call 'createNewQuestion', question, (error, result) ->

      console.log error, result

      if not error
        Session.set("subscribedQuestion", questionId)
        Session.set('askingQuestion?', false)

        # Decrement karma
        Session.set('karma', Session.get('karma') - karmaOffered)

        # Set question from prompt to null
        Session.set('questionFromLandingPrompt', null)

    # questionId = Questions.insert question

