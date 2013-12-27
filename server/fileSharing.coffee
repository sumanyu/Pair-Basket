Knox = Meteor.require("knox")

knox = null
S3 = null

Meteor.methods
  S3config: (object) ->
    knox = Knox.createClient(object)
    S3 = 
      directory: object.directory || "/"

  # Uploads file
  S3upload: (file, classroomSessionId) ->
    console.log "Uploading file to classroom session #{classroomSessionId}"

    # Set file unique id
    extension = (file.name).match(/\.[0-9a-z]{1,5}$/i) || ""
    _filename = file.name
    file.name = Meteor.uuid() + extension
    path = S3.directory + file.name

    buffer = new Buffer(file.data)

    # Run putBuffer using sync utility. Fn waits until result is available.
    # Then it calls done with url set to knox.http(path)
    url = Async.runSync (done) ->
      knox.putBuffer buffer, path, {"Content-Type":file.type,"Content-Length":buffer.length}, (error, result) ->
        if result
          done(null, knox.http(path))
        else
          console.log error

    _file = 
      url: url.result
      name: _filename
      dateCreated: new Date

    console.log _file

    totalMessage = 
      message: "#{Meteor.user().profile.name} has uploaded #{_filename}."
      user:
        id: @userId
        name: Meteor.user().profile.name
      type: 'alert'
      dateCreated: new Date

    # Append file to list of shared files
    ClassroomSession.update {_id: classroomSessionId}, {$push: {sharedFiles: _file, messages: totalMessage}}

    return url

  # Deletes file on S3 server
  S3delete: (path) ->
    knox.deleteFile path, (error, result) ->
      if error
        console.log "Error deleting S3 file"
        console.log error
      else
        console.log result