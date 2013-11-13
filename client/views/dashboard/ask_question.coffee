focusText = (i) ->
  i.focus()
  i.select()

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

# Trim left and right
unless String::trim then String::trim = -> @replace /^\s+|\s+$/g, ""

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
    text = $('textarea#question-text').val()
    karmaOffered = parseInt($('input#karma-offered').val())

    question = 
      title: title
      userId: '1'
      text: text
      tags: tags
      karmaOffered: karmaOffered
      dateCreated: new Date()
      dateModified: new Date()
      status: "Active"

    questionId = Questions.insert question

    Session.set("subscribedQuestion", questionId)
    Session.set('askingQuestion?', false)

    # Decrement karma
    Session.set('karma', Session.get('karma') - karmaOffered)

    # Set question from prompt to null
    Session.set('questionFromLandingPrompt', null)