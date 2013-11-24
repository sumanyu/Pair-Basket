@Feedback = new Meteor.Collection2("feedback",
  schema:
    feedbackText:
      type: String
    userId:
      type: String
      label: "userId"
    dateCreated:
      type: Date
      label: "Date when this question was created"
)