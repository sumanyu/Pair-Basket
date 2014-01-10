Template.fileSharing.helpers
  sharedFiles: ->
    result = getCurrentClassroomSession(['sharedFiles'])?.sharedFiles || []

Template.fileSharing.events
  "click .drag-and-drop-files": (e) ->
    $('input[type=file]').click()