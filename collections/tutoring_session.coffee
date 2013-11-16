@TutoringSession = new Meteor.Collection("TutoringSession")

@TutoringSession.allow
  # User must be logged in and document must be owned by user
  'insert': (userId, doc) ->
    userId and (userId in [doc.tutorId, doc.tuteeId])

  # User must be logged in and document must be owned by user
  'update': (userId, doc) ->
    userId and (userId in [doc.tutorId, doc.tuteeId])

@TutoringSession.deny
  'update': (userId, docs, fields, modifier) ->
    tests = ['sessionId', 'tutorId', 'tuteeId'].map (test) -> test in fields
    tests.reduce (total, test) -> test or total