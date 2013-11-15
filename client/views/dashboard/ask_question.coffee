focusText = (i) ->
  i.focus()
  i.select()

Template.ask_question.helpers
  getFirstQuestion: =>
    Session.get('questionFromLandingPrompt') if Session.get('questionFromLandingPrompt')

  # validForm: ->
  #   parseInt($('input#karma-offered').val()) <= Meteor.user().karma

Template.ask_question.rendered = ->
  selector = $('.questionForm').find("#question-tags") 
  focusText(selector)

Template.ask_question.maxKarma = ->
  Meteor.user().karma

# Trim left and right
unless String::trim then String::trim = -> @replace /^\s+|\s+$/g, ""

Template.ask_question.events =
  'click .overlay' : (e, selector) ->
    Session.set('questionFromLandingPrompt', null)
    Session.set('askingQuestion?', false)

  'submit' : (e, selector) ->
    e.preventDefault()

    stringTags = $('input#question-tags').val()
    tagsList = stringTags.split(",")

    tags = if tagsList.length is 0
            [stringTags].map (tag) -> tag.trim()
          else
            tagsList.map (tag) -> tag.trim()

    category = $('input#question-category').val()
    question = $('textarea#question-text').val()
    karmaOffered = parseInt($('input#karma-offered').val())

    question = 
      category: category
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
        Session.set("subscribedQuestion", result)
        Session.set('askingQuestion?', false)

        # Set question from prompt to null
        Session.set('questionFromLandingPrompt', null)

    # questionId = Questions.insert question

