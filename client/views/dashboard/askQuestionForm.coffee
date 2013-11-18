Template.askQuestionForm.helpers
  getFirstQuestion: =>
    Session.get('questionFromLandingPrompt') if Session.get('questionFromLandingPrompt')

  # validForm: ->
  #   parseInt($('input#karma-offered').val()) <= Meteor.user().karma

Template.askQuestionForm.rendered = ->
  selector = $('.questionForm').find("#question-tags") 
  focusText(selector)

Template.askQuestionForm.maxKarma = ->
  Meteor.user().karma

Template.askQuestionForm.events =
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

    category = $('select#question-category').val()
    questionText = $('textarea#question-text').val()
    karmaOffered = parseInt($('input#karma-offered').val())

    question = 
      category: category
      # userId: '1'
      questionText: questionText
      tags: tags
      karmaOffered: karmaOffered
      # dateCreated: new Date()
      # dateModified: new Date()
      # status: "Active"

    Meteor.call 'createNewQuestion', question, (error, result) ->

      console.log error, result

      if not error
        Session.set("subscribedQuestion", result)
        Session.set('askingQuestion?', false)

        # Set question from prompt to null
        Session.set('questionFromLandingPrompt', null)

    # questionId = Questions.insert question

