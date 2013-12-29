@populateQuestions = ->
  if Meteor.isServer and Questions.find().count() is 0
  # if Questions.find().count() is 0
    questions = [
      category: "english"
      userId: '1'
      questionText: "How do you structure an essay to be creative but effective?"
      tags: [
        "essay",
        "writing"]
      karmaOffered: 50
      dateCreated: new Date()
      dateModified: new Date()
      status: "resolved"
    ,
      category: "computer"
      userId: '1'
      questionText: 'What is the difference between atan and atan2 functions in the cmath library in C++?'
      tags: [
        "c++",
        "programming"]
      karmaOffered: 20
      dateCreated: new Date()
      dateModified: new Date()
      status: "resolved"
    ,
      category: "math"
      userId: '1'
      questionText: 'How do you use the area of a circle to find the volume of a cylinder?'
      tags: [
        "geometry",
        "volume"]
      karmaOffered: 80
      dateCreated: new Date()
      dateModified: new Date()
      status: "resolved"
    ,
      category: "science"
      userId: '1'
      questionText: 'How do you draw a free body diagram with deformable solids?'
      tags: [
        "deformable_solids",
        "physics"]
      karmaOffered: 45
      dateCreated: new Date()
      dateModified: new Date()
      status: "resolved"
    ,
      category: "science"
      userId: '1'
      questionText: 'Why is citric acid a key part of the Krebs Cycle?'
      tags: [
        "biology",
        "metabolism"]
      karmaOffered: 57
      dateCreated: new Date()
      dateModified: new Date()
      status: "resolved"
    ,
      category: "business"
      userId: '1'
      questionText: 'How do banks create value by lending money they do not own?'
      tags: [
        "finance",
        "multiplier_effect"]
      karmaOffered: 92
      dateCreated: new Date()
      dateModified: new Date()
      status: "resolved"
    ]

    for question in questions
      Questions.insert question
      # console.log question

@dropAll = ->
  SessionRequest.remove({})
  SessionResponse.remove({})
  Questions.remove({})
  # ClassroomSession.remove({})
  populateQuestions()
  populateSkills()


@populateSkills = ->
  if Meteor.isServer and Skills.find().count() is 0
    skills = [
      category: "math"
      tags: ["calculus"]
      name: "integral"
      description: "integration is a fundamental technique in calculus"
      dateCreated: new Date()
      status: "active"
    ,
      category: "math"
      tags: ["calculus"]
      name: "derivative"
      description: "derivative is used to find the slope of a function"
      dateCreated: new Date()
      status: "active"
    ,
      category: "math"
      tags: ["algebra"]
      name: "arithmetic"
      description: "addition, subtraction, multiplication, division"
      dateCreated: new Date()
      status: "active"
    ,
      category: "computer"
      tags: ["programming"]
      name: "java"
      description: "java is a popular object-oriented programming language"
      dateCreated: new Date()
      status: "active"
    ,
      category: "computer"
      tags: ["programming"]
      name: "python"
      description: "python is a versatile scripting language"
      dateCreated: new Date()
      status: "active"
    ,
      category: "computer"
      tags: ["database"]
      name: "mySQL"
      description: "MySQL is a query language"
      dateCreated: new Date()
      status: "active"
    ]

    for skill in skills
      Skills.insert skill