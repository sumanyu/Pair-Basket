@RemotePad = (padId, pad) ->

  users = {}

  positionPointer = (pointer, position) ->
    pointer.css
      top: position.y + 10
      left: position.x + 10
  
  LineStream.on padId + ":dragstart", (nickname, position, color, mode) ->
    pointer = $($("#tmpl-nickname").text())
    pointer.text nickname
    positionPointer pointer, position
    $("body").append pointer

    users[nickname] =
      color: color
      from: position
      pointer: pointer
      mode: mode

  LineStream.on padId + ":dragend", (nickname) ->
    user = users[nickname]
    if user
      user.pointer.remove()
      users[nickname] = `undefined`
      # Reset local pad's mode to what it had before remote person switched it
      pad.initializeModeInitialConditions()

  # We use drawRemoteLine to mimic the local pad's drawing conditions 
  # to that of the remote pad without ever changing the drawing mode
  # of the local pad. This allows us to treat every draw instruction
  # from a remote pad as a transaction, by the end of which, the local
  # pad reverts its conditions to its initial state via initializeModeInitialConditions

  LineStream.on padId + ":drag", (nickname, to) ->
    user = users[nickname]
    if user
      pad.drawRemoteLine user.from, to, user.color, user.mode
      positionPointer user.pointer, to
      user.from = to

  LineStream.on padId + ":wipe", (nickname) ->
    pad.wipe()

  close: ->
    LineStream.removeAllListeners padId + ":dragstart"
    LineStream.removeAllListeners padId + ":dragend"
    LineStream.removeAllListeners padId + ":drag"
    LineStream.removeAllListeners padId + ":wipe"