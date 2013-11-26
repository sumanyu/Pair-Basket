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

  LineStream.on padId + ":drag", (nickname, to) ->
    user = users[nickname]
    if user
      pad.drawRemoteLine user.from, to, user.color, user.mode
      positionPointer user.pointer, to
      user.from = to

  LineStream.on padId + ":wipe", (nickname) ->
    pad.wipe()

  LineStream.on padId + ":draw", (nickname) ->
    # Draw on local pad
    pad.startRemoteDrawMode()

  LineStream.on padId + ":erase", (nickname) ->
    # Erase on local pad
    pad.startRemoteEraseMode()

  close: ->
    LineStream.removeAllListeners padId + ":dragstart"
    LineStream.removeAllListeners padId + ":dragend"
    LineStream.removeAllListeners padId + ":drag"
    LineStream.removeAllListeners padId + ":wipe"