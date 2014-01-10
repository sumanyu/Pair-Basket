Template.fileSharing.helpers
  sharedFiles: ->
    result = getCurrentClassroomSession(['sharedFiles'])?.sharedFiles || []

Template.fileSharing.events
  "click .drag-and-drop-files": (e) ->
    # $('input[type=file]').click()

  "drop .drag-and-drop-files": (e) ->
    e.preventDefault()
    e.stopPropagation()
    _.each e.dataTransfer.files, uploadFileToS3

  "dragover .drag-and-drop-files": (e) ->
    e.preventDefault()
    e.stopPropagation()
    e.dataTransfer.dropEffect = 'copy'