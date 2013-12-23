@focusText = (i) ->
  i.focus()

# Trim left and right
unless String::trim then String::trim = -> @replace /^\s+|\s+$/g, ""

@areElementsNonEmpty = (list) ->
  list.every (input) -> input.length

navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia
@moz = !!navigator.mozGetUserMedia

@playRemoteStream = (remoteStream) ->
  console.log "Remote stream"
  console.log remoteStream
  # Play it locally in the browser
  audio = document.createElement('audio')

  # Mozilla/Chrome specific logic
  unless moz
    audio.src = window.webkitURL.createObjectURL(remoteStream)
  else
    audio.mozSrcObject = remoteStream

  # Auto play
  audio.controls = true
  audio.autoplay = true
  audio.play()

# Creates a query for which fields we want from a query
# For example: ClassroomSession.findOne({_id: Session.get('classroomSessionId')}, {field_1: 1, field_2: 1 })
@getCurrentClassroomSession = (_fields) ->
  query = {}

  # Create a query of which fields user wants
  if _fields

    # Check if single argument
    if not $.isArray(_fields)
      _fields = [_fields]

    query =
      fields: {}

    _fields.forEach (field) -> query.fields[field] = 1

  ClassroomSession.findOne({_id: Session.get('classroomSessionId')}, query)

# Returns the other user, whichever one that is (tutor or tutee)
@getChatPartner = ->
  currentUser = Meteor.user()
  currentSession = getCurrentClassroomSession(['tutor', 'tutee'])
  tutor = currentSession.tutor
  tutee = currentSession.tutee

  if currentUser._id is tutor.id then tutee else tutor

# Convenient way to set multiple Session.set
# Takes a map of keys and values, assigns the session based on those keys and values
@setSessionVars = (sessionMap) ->
  _.pairs(sessionMap).forEach (pair) ->
    Session.set(_.first(pair), _.last(pair))

# Convenient way to set an array of session variables with one value
@setSessionVarsWithValue = (value, sessionKeys) ->
  sessionKeys.forEach (key) -> Session.set(key, value)