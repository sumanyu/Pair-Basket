# @Questions = new Meteor.Collection("questions")

questionsSchema =   
  schema:
    category:
      type: String
      label: "math, science, english, social_science, computers, business, foreign_language"
      max: 200
    userId:
      type: String
      label: "userId"
    questionText:
      type: String
    skills:
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

@Questions = new Meteor.Collection2("questions", questionsSchema)
