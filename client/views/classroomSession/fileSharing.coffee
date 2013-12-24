Template.fileSharing.helpers
  sharedFiles: ->
    result = getCurrentClassroomSession(['sharedFiles']).sharedFiles || []