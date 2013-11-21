# Validation is not playing well with messages
# messageSchema = 
#   schema:
#     userId:
#       type: String
#     message:
#       type: String

tutoringSessionSchema = 
  schema:
    tutorId:
      type: String
    tuteeId:
      type: String
    tutorStatus:
      type: Boolean
    tuteeStatus:
      type: Boolean
    sessionId:
      type: String
    questionId:
      type: String
    # messages:
    #   type: Object
  virtualFields: 
    # False only when both tutor and tutee are inactive
    classroomStatus: (tutoringSession) ->
      not (tutoringSession.tutorStatus or tutoringSession.tuteeStatus)

@TutoringSession = new Meteor.Collection2("TutoringSession", tutoringSessionSchema)

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