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

# Template.ask_question.rendered = ->
#   $('input#question-tags').typeahead
#     name: 'tags',                                                          
#     local: ['Mathematics', 'Grade 12', 'Linear Algebra']                                         
#     limit: 3                                                                   

#   $('input#question-title').typeahead
#     name: 'tags',                                                          
#     local: ['Mathematics', 'Grade 12', 'Linear Algebra']                                         
#     limit: 3 

Template.ask_question.events =
  'click .overlay' : (e, selector) ->
    Session.set('questionFromLandingPrompt', null)
    Session.set('askingQuestion?', false)

  'click input#question-submit' : (e, selector) ->
    e.preventDefault()

    # console.log("clicked question submit")
    stringTags = $('input#question-tags').val()
    tagsList = stringTags.split(",")

    tags = if tagsList.length is 0
            [stringTags].map (tag) -> tag.trim()
          else
            tagsList.map (tag) -> tag.trim()

    # console.log stringTags
    
    # console.log tags
    title = $('input#question-title').val()
    text = $('textarea#question-text').val()
    karmaOffered = parseInt($('input#karma-offered').val())

    # console.log tags
    # console.log title
    # console.log text
    # console.log karma_offered

    question = 
      title: title
      userId: '1'
      text: text
      tags: tags
      karmaOffered: karmaOffered
      dateCreated: new Date()
      dateModified: new Date()
      status: "Active"

    # console.log(question)
    questionId = Questions.insert question
    # console.log questionId

    Session.set("subscribedQuestion", questionId)
    Session.set('askingQuestion?', false)

    # Decrement karma
    Session.set('karma', Session.get('karma') - karmaOffered)

    # Set question from prompt to null
    Session.set('questionFromLandingPrompt', null)

    # Video stuff
        
    # Session.set('waitingForTutor?', true)

    # wait_for_tutor = ->
    #   Meteor.setTimeout found_tutor, 4000

    # found_tutor = ->
    #   Session.set('waitingForTutor?', false)
    #   Session.set('foundTutor?', true)

    # wait_for_tutor()