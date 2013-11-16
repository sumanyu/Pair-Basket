# @Questions = new Meteor.Collection("questions")

questionsSchema =   
  schema:
    category:
      type: String
      label: "Category"
      max: 200
    userId:
      type: String
      label: "userId"
    questionText:
      type: String
    tags:
      type: [String]
    karmaOffered:
      type: Number
      label: "Karma offered"
      min: 0
    dateCreated:
      type: Date
      label: "Date when this question was created"
    dateModified:
      type: Date
      label: "Date when this question was modified"
    status:
      type: String
      label: "waiting, session, resolved, deleted"
  virtualFields: 
    tagsJoined: (question) ->
      question.tags.reduce (current, total) -> "#{total}, #{current}"

@Questions = new Meteor.Collection2("questions", questionsSchema)