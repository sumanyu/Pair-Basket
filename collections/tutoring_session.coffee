@TutoringSession = new Meteor.Collection("TutoringSession")

TutoringSession.allow
  # User must be logged in and document must be owned by user
  'insert': (userId, doc) ->
    console.log userId
    console.log doc
    userId and (userId in [doc.tutorId, doc.tuteeId])

  # User must be logged in and document must be owned by user
  'update': (userId, doc) ->
    userId and (userId in [doc.tutorId, doc.tuteeId])

TutoringSession.deny
  'update': (userId, docs, fields, modifier) ->
    ['sessionId', 'tutorId', 'tuteeId'].reduce (total, test) -> 
      _.contains(fields, test) or total