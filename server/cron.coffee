cronJob = Meteor.require("cron").CronJob

cleanUpSharedFilesOfOldSessions = new cronJob(
  # Clean up shared files of old sessions every 6 hours
  cronTime: '0 0,6,12,18 * * *'
  onTick: ->
    console.log "Ticking, tick tock"
    
  start: true
)

cleanUpSharedFilesOfOldSessions.start()