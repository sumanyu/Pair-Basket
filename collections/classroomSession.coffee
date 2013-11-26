# Can't use more than one nested SimpleSchema

classroomSessionSessageSchema = new SimpleSchema
  'userId':
    type: String
  'userName':
    type: String
  'message':
    type: String

classroomSessionUserSchema = new SimpleSchema
  'id':
    type: String
  'name':
    type: String
  'school':
    type: String

classroomSessionSchema = 
  schema:
    'tutor':
      type: classroomSessionUserSchema
    'tutee':
      type: classroomSessionUserSchema
    'tutorStatus':
      type: Boolean
    'tuteeStatus':
      type: Boolean
    'questionId':
      type: String
    'messages':
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
    userId and (userId in [doc.tutor.id, doc.tutee.id])

  # User must be logged in and document must be owned by user
  'update': (userId, doc) ->
    console.log userId
    console.log doc
    userId and (userId in [doc.tutor.id, doc.tutee.id])

@ClassroomSession.deny
  # Disallow modification of tutorId, tuteeId
  'update': (userId, docs, fields, modifier) ->
    tests = ['tutorId', 'tuteeId'].map (test) -> test in fields
    tests.reduce (total, test) -> test or total