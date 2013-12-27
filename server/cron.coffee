cronJob = Meteor.require("cron").CronJob

cleanUpSharedFilesOfOldSessions = new cronJob(
  # Clean up shared files of old sessions every 6 hours
  cronTime: '0 0,6,12,18 * * *'
  onTick: ->
    # Find all active sessions older than 6 hours and delete their shared files from S3 server
    ClassroomSession.find(
      {$and: [
        # Older than 6 hours
        {dateCreated: { $lte: new Date( (new Date)*1 - 1000*3600*6 ) }}, 
        # Haven't ended properly
        {$or: [ 
          {'tutor.status': true},
          {'tutee.status': true}
        ]}
      ]}
    ).forEach (classroomSession) ->
      deleteSharedFilesFromClassroomSession(classroomSession)
  start: true
)

cleanUpSharedFilesOfOldSessions.start()