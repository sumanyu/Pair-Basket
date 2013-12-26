# Add comments for each

Handlebars.registerHelper(
  "underscoreToSpace", 
  (string) ->
    string.split("_").join(" ")
)

Handlebars.registerHelper(
  "allCategory", -> allCategory
)

Handlebars.registerHelper(
  "allSchool", -> allSchool
)

# File uploading helper
Handlebars.registerHelper(
  "S3", 
  (options) ->
    uploadOptions = options.hash
    template = options.fn
    callback = uploadOptions.callback

    return unless template

    html = Spark.isolate -> template()

    html = Spark.attachEvents(
      "change input[type=file]": (e) ->
        files = e.currentTarget.files

        _.each files, (file) ->
          reader = new FileReader
          fileData =
            name: file.name
            size: file.size
            type: file.type

          reader.onload = ->
            fileData.data = new Uint8Array(reader.result)
            Meteor.call "S3upload", fileData, Session.get("classroomSessionId"), (error, result) ->
              if error
                console.log error
              else
                console.log result

          reader.readAsArrayBuffer file

    , html)

    html
)