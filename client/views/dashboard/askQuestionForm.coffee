Template.askQuestionForm.helpers
  getFirstQuestion: =>
    Session.get('questionFromLandingPrompt') if Session.get('questionFromLandingPrompt')

  # validForm: ->
  #   parseInt($('input#karma-offered').val()) <= Meteor.user().karma

Template.askQuestionForm.rendered = ->
  selector = $('.questionForm').find("#question-category") 
  focusText(selector)

Template.askQuestionForm.maxKarma = ->
  Meteor.user().karma

Template.askQuestionForm.events =
  'click .close-popup-button' : (e, selector) ->
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
      questionText: questionText
      tags: tags
      karmaOffered: karmaOffered

    Meteor.call 'createNewQuestion', question, (error, result) ->

      console.log error, result

      if not error
        # Auto run will automatically set `subscribedQuestion`
        # Session.set("subscribedQuestion", result)
        Session.set('askingQuestion?', false)

        # Set question from prompt to null
        Session.set('questionFromLandingPrompt', null)

        Session.set("subscribedQuestion", result)

# Event listener for listening for classroom requests
Deps.autorun ->
  if Session.get('subscribedQuestion')
    ClassroomStream.on "request:#{Session.get('subscribedQuestion')}", (message) ->
      console.log "Someone clicked accept to my question"
      Session.set('subscribedResponse', message)

# Subscribed question will always hold the subscribed question
Deps.autorun ->
  if Meteor.userId()
    Session.set("subscribedQuestion", Questions.findOne({userId: Meteor.userId()})?._id)
