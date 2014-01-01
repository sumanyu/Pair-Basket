Template.askQuestionForm.helpers
  getFirstQuestion: =>
    Session.get('questionFromLandingPrompt') if Session.get('questionFromLandingPrompt')

  questionFormError: =>
    Session.get('questionFormError')

Template.askQuestionForm.rendered = ->
  selector = $('.questionForm').find("#question-category") 
  focusText(selector)

  skillData = []
  skills = Skills.find()

  skills.forEach (skill) ->
    skillData.push
      id: skill._id
      text: skill.name

  $("#question-skills").select2({
    placeholder: 'Disciplines'
    multiple: true
    data: skillData
  })

Template.askQuestionForm.maxKarma = ->
  Meteor.user().karma

Template.askQuestionForm.events =
  'click .close-popup-button' : (e, selector) ->
    Session.set('questionFromLandingPrompt', null)
    Session.set('askingQuestion?', false)
    Session.set('questionFormError', null)

  'submit' : (e, selector) ->
    e.preventDefault()

    # get array of selected skill IDs
    skills = $('#s2id_question-skills').select2("val")

    category = $('select#question-category').val()
    questionText = $('textarea#question-text').val()
    karmaOffered = parseInt($('input#karma-offered').val())

    question = 
      category: category
      questionText: questionText
      skills: skills
      karmaOffered: karmaOffered

    # Server creates question and returns questionId
    Meteor.call 'createNewQuestion', question, (error, questionId) ->

      console.log "Creating new question"

      if error
        console.log "Error...", error
        Session.set("questionFormError", error.reason)
      else
        console.log "questionId: #{questionId}"
        
        Session.set("subscribedQuestion", questionId)
        Session.set('askingQuestion?', false)
        Session.set('questionFormError', null)

        # Set question from prompt to null
        Session.set('questionFromLandingPrompt', null)