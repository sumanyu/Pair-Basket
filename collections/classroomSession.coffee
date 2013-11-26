classroomSessionUserSchema = new SimpleSchema
  id:
    type: String
  name: 
    type: String

classroomSessionSessageSchema = new SimpleSchema
  user:
    type: [classroomSessionUserSchema]
  message:
    type: String

classroomSessionSchema = 
  schema:
    tutorId:
      type: String
    tuteeId:
      type: String
    tutorStatus:
      type: Boolean
    tuteeStatus:
      type: Boolean
    questionId:
      type: String
    messages:
      type: [classroomSessionSessageSchema]
  virtualFields: 
    # False only when both tutor and tutee are inactive
    # Unfortunately, you can't query on virtual fields
    classroomStatus: (classroomSession) ->
      classroomSession.tutorStatus or classroomSession.tuteeStatus

@ClassroomSession = new Meteor.Collection2("ClassroomSession", classroomSessionSchema)

@ClassroomSession.allow
  # User must be logged in and document must be owned by user
  'insert': (userId, doc) ->
    userId and (userId in [doc.tutorId, doc.tuteeId])

  # User must be logged in and document must be owned by user
  'update': (userId, doc) ->
    userId and (userId in [doc.tutorId, doc.tuteeId])

@ClassroomSession.deny
  'update': (userId, docs, fields, modifier) ->
    tests = ['classroomSessionId', 'tutorId', 'tuteeId'].map (test) -> test in fields
    tests.reduce (total, test) -> test or total