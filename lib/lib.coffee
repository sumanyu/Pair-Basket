@allCategory = [
  'math',
  'science',
  'english',
  'social_science',
  'computer',
  'business',
  'foreign_language',
]

if Meteor.isClient
  @focusText = (i) ->
    i.focus()
    i.select()

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