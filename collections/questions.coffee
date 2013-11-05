@Questions = new Meteor.Collection2("questions",
  schema:
    title:
      type: String
      label: "Title"
      max: 200
    userId:
      type: String
      label: "userId"
    category:
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
      label: "Resolved, Inactive, Expired, Deleted"
  virtualFields: 
    tagsJoined: (question) ->
      question.tags.reduce (current, total) -> "#{total}, #{current}"
)

# Questions.allow
#   insert: (title, userId, category, tags, karma_offered) ->
#   	return true

# if Meteor.isServer and Questions.find().count() is 0
if Questions.find().count() is 0
  questions = [
    title: "What is 2+2?"
    userId: '1'
    category: 'Math'
    tags: [
      "Addition"
    ,
      "Grade 1"
    ]
    karmaOffered: 50
    dateCreated: new Date()
    dateModified: new Date()
    status: "Active"
  ,
    title: "What is photosynthesis?"
    userId: '1'
    category: 'Biology'
    tags: [
      "Plants"
    ,
      "Grade 5"
    ]
    karmaOffered: 100
    dateCreated: new Date()
    dateModified: new Date()
    status: "Inactive"
  ]

  for question in questions
    Questions.insert question
    # console.log question
