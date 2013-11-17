@TutoringSession = new Meteor.Collection("TutoringSession")

messageSchema = 
  schema:
    userId:
      type: String
    message:
      type: String

tutoringSessionSchema = 
  schema:
    tutorId:
      type: String
    tuteeId:
      type: String
    hasTutorEndedSession:
      type: Boolean
    hasTuteeEndedSession:
      type: Boolean
    sessionId:
      type: String
    questionId:
      type: String
    status:
      type: String
      allowedValues: ['active', 'resolved']
    messages:
      type: [messageSchema]


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