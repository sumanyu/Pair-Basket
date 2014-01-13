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

        _.each files, uploadFileToS3

    , html)

    html
)