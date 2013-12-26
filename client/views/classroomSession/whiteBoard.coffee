pad = undefined
remotePad = undefined

Template.whiteBoard.rendered = ->
  if pad
    pad.close()
    remotePad.close()

  if $('canvas').length > 0
    user = Meteor.user()?._id || "Anonymous"

    classroomSessionId = Session.get("classroomSessionId")
    pad = new Pad($('canvas'), classroomSessionId, user)
    remotePad = new RemotePad(classroomSessionId, pad)

Template.whiteBoard.events
  'click .draw': (e, s) ->
    pad.startDrawMode()

  'click .erase': (e, s) ->
    pad.startEraseMode()

  'click .clear-blackboard': (e, s) ->
    pad.wipe true