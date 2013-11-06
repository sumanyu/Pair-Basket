Meteor.startup ->
  console.log "Server is starting!"
  console.log Questions.find().count()

Meteor.publish "questions", ->
  Questions.find({})

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
    karmaOffered: 30
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
    karmaOffered: 50
    dateCreated: new Date()
    dateModified: new Date()
    status: "Active"
  ,
    title: "In elastic collisions, why is momentum conserved?"
    userId: '1'
    category: 'Physics'
    tags: [
      "Kinematics"
    ,
      "Energy"
    ,
      "Grade 10"
    ]
    karmaOffered: 80
    dateCreated: new Date()
    dateModified: new Date()
    status: "Active"
  ]

  for question in questions
    Questions.insert question
    # console.log question