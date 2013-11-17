@RemotePad = (padId, pad) ->

  users = {}

  positionPointer = (pointer, position) ->
    pointer.css
      top: position.y + 10
      left: position.x + 10
  
  LineStream.on padId + ":dragstart", (nickname, position, color) ->
    pointer = $($("#tmpl-nickname").text())
    pointer.text nickname
    positionPointer pointer, position
    $("body").append pointer
    users[nickname] =
      color: color
      from: position
      pointer: pointer

  LineStream.on padId + ":dragend", (nickname) ->
    user = users[nickname]
    if user
      user.pointer.remove()
      users[nickname] = `undefined`

  LineStream.on padId + ":drag", (nickname, to) ->
    user = users[nickname]
    if user
      pad.drawLine user.from, to, user.color
      positionPointer user.pointer, to
      user.from = to

  LineStream.on padId + ":wipe", (nickname) ->
    pad.wipe()

  close: ->
    LineStream.removeAllListeners padId + ":dragstart"
    LineStream.removeAllListeners padId + ":dragend"
    LineStream.removeAllListeners padId + ":drag"
    LineStream.removeAllListeners padId + ":wipe"