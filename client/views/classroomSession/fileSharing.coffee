Template.fileSharing.helpers
  sharedFiles: ->
    result = getCurrentClassroomSession(['filesShared']).filesShared || []