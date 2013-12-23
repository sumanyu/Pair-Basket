Knox = Meteor.require("knox")

knox = null
S3 = null

Meteor.methods
  S3config: (object) ->
    knox = Knox.createClient(object)
    S3 = 
      directory: object.directory || "/"

  # Uploads file
  S3upload: (file, context) ->
    # Set file unique id
    extension = (file.name).match(/\.[0-9a-z]{1,5}$/i) || ""
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

    console.log url

    return url

  # Deletes file on S3 server
  S3delete: (path) ->
    knox.deleteFile path, (error, result) ->
      unless error
        console.log result
      else
        console.log error