# @Questions = new Meteor.Collection("questions")

# We might use Collection2 later
@Questions = new Meteor.Collection2("questions",
  schema:
    category:
      type: String
      label: "math, science, english, social_science, computers, business, second_language"
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
)