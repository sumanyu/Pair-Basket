# This is called once when the page is created. We'll treat this as user joining the session.
Template.classroomSessionPage.created = ->
  console.log "Creating classroom session page"
  Meteor.call 'enterClassroomSession', Session.get('classroomSessionId')

# This is called once when the classroom session is destroyed. It's not called if user goes to dashbaord.
# We'll treat this as user ending session
Template.classroomSessionPage.destroyed = ->
  console.log "Destroying classroom session page"

Template.classroomSessionSidebar.helpers
  whiteboardIsSelected: ->
    Session.get('whiteboardIsSelected?')

  fileIsSelected: ->
    Session.get('fileIsSelected?')

  wolframIsSelected: ->
    Session.get('wolframIsSelected?')

Template.classroomSessionSidebar.events 
  "click .whiteboard-button": (e, s) ->
    Session.set('whiteboardIsSelected?', true)
    setSessionVarsWithValue false, ['fileIsSelected?', 'wolframIsSelected?']

  "click .file-button": (e, s) ->
    Session.set('fileIsSelected?', true)
    setSessionVarsWithValue false, ['whiteboardIsSelected?', 'wolframIsSelected?']

  "click .wolfram-button": (e, s) ->
    Session.set('wolframIsSelected?', true)
    setSessionVarsWithValue false, ['fileIsSelected?', 'whiteboardIsSelected?']

  "click .end-session": (e, s) ->
    setSessionVarsWithValue false , ['foundTutor?', 'askingQuestion?']

    Meteor.call 'endClassroomSession', Session.get("classroomSessionId"), (err, result) ->
      console.log "Calling end classroom session"

      if err
        console.log err
      else
        synchronizedCloseAudioCalls()
        Router.go('/dashboard')

Template.classroomSessionPage.rendered = ->
  showActiveClassroomSessionTool()