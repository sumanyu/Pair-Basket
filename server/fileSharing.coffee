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
    extension = (file.name).match(/\.[0-9a-z]{1,5}$/i) || ""
    file.name = Meteor.uuid() + extension
    path = S3.directory + file.name

    buffer = new Buffer(file.data)

    url = Async.runSync (done) ->
      console.log done

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