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
  "allSchool", ->
    [
      "University_of_Waterloo"
      "High_School"
      "McGill_University"
      "McMaster_University"
      "Ryerson_University"
      "McGill_University"
      "University_of_British Columbia"
      "University_of_Toronto"
      "University_of_Western Ontario"
      "York_University"
      "Other"
    ]
)

Handlebars.registerHelper "S3", (options) ->
  uploadOptions = options.hash
  template = options.fn
  callback = uploadOptions.callback
  context = @

  return unless template

  html = Spark.isolate(->
    template()
  )

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
          Meteor.call "S3upload", fileData, context, callback

        reader.readAsArrayBuffer file

  , html)

  html