# Manages client to client communication
chatStream = new Meteor.Stream("chat")

@LineStream = new Meteor.Stream("lines")

# Temporary local chat collection
chatCollection = new Meteor.Collection(null)

chatStream.on "chat", (message) ->
  chatCollection.insert
    userId: @userId
    message: message

Template.chatBox.helpers 
  messages: ->
    # fetch all chat messages
    chatCollection.find()

Template.chatMessage.helpers 
  user: ->
    @userId

sendMessage = ->
  message = $("#chat-message").val()

  chatCollection.insert
    userId: "me"
    message: message

  # Broadcast that message to all clients
  chatStream.emit "chat", message
  $("#chat-message").val ""

Template.chatBox.events 
  "keydown #chat-message": (e, s) ->
    if e.keyCode is 13
      e.preventDefault()
      sendMessage()

  "click #send": (e, s) ->
    sendMessage()

Template.whiteBoard.created = ->
  # Ensures whiteboard layout has loaded before executing JS in Deps.autorun
  Session.set("whiteboardLoaded?", true)

pad = undefined
remotePad = undefined

Meteor.startup ->
  Session.set("whiteboardLoaded?", false)

  Deps.autorun ->
    if pad
      pad.close()
      remotePad.close()

    sessionId = Session.get("sessionId")

    if Session.get("whiteboardLoaded?")
      pad = new Pad(sessionId)
      remotePad = new RemotePad(sessionId, pad)

# $ ->
#   #Clear Blackboard
#   $("body").on "click", "#wipe", ->
#     pad.wipe true

#   #Create New
#   $("body").on "click", "#create-new", ->
#     newPadId = Random.id()
#     Meteor.Router.to "pad", newPadId

# Template.whiteBoard.helpers
#   startPad: ->

#     getRandomColor = ->
#       letters = "0123456789ABCDEF".split("")
#       color = "#"
#       i = 0

#       while i < 6
#         color += letters[Math.round(Math.random() * 15)]
#         i++
#       color

#     @Pad = (id) ->
#       onDrag = (event) ->
#         if drawing
#           to = getPosition(event)
#           drawLine from, to, color
#           LineStream.emit id + ":drag", nickname, to
#           from = to
#           skipCount = 0
#       onDragStart = (event) ->
#         drawing = true
#         from = getPosition(event)
#         LineStream.emit id + ":dragstart", nickname, from, color
#       onDragEnd = ->
#         drawing = false
#         LineStream.emit id + ":dragend", nickname
#       getPosition = (event) ->
#         x: parseInt(event.gesture.center.pageX)
#         y: parseInt(event.gesture.center.pageY)
#       drawLine = (from, to, color) ->
#         ctx.strokeStyle = color
#         ctx.beginPath()
#         ctx.moveTo from.x, from.y
#         ctx.lineTo to.x, to.y
#         ctx.closePath()
#         ctx.stroke()
#       setNickname = (name) ->
#         nickname = name
#         $("#show-nickname b").text nickname
#         localStorage.setItem "nickname", nickname
#         color = localStorage.getItem("color-" + nickname)
#         unless color
#           color = getRandomColor()
#           localStorage.setItem "color-" + nickname, color
#       wipe = (emitAlso) ->
#         ctx.fillRect 0, 0, canvas.width(), canvas.height()
#         LineStream.emit id + ":wipe", nickname  if emitAlso
#       canvas = $("canvas")
#       ctx = canvas[0].getContext("2d")
#       drawing = false
#       from = undefined
#       skipCount = 0
#       nickname = undefined
#       color = undefined
#       setNickname localStorage.getItem("nickname") or Random.id()
#       LineStream.emit "pad", id
#       pad = canvas.attr(
#         width: $(window).width()
#         height: $(window).height()
#       ).hammer()
#       pad.on "dragstart", onDragStart
#       pad.on "dragend", onDragEnd
#       pad.on "drag", onDrag
#       ctx.strokeStyle = color
#       ctx.fillStyle = "#000000"
#       ctx.lineCap = "round"
#       ctx.lineWidth = 3
#       ctx.fillRect 0, 0, canvas.width(), canvas.height()
#       document.ontouchmove = (event) ->
#         event.preventDefault()

#       @drawLine = drawLine
#       @wipe = wipe
#       @setNickname = setNickname
#       @close = ->
#         pad.off "dragstart", onDragStart
#         pad.off "dragend", onDragEnd
#         pad.off "drag", onDrag



