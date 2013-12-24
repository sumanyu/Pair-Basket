Template.fileSharing.helpers
  sharedFiles: ->
    result = getCurrentClassroomSession(['sharedFiles']).sharedFiles || []
    console.log result
    result