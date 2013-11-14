class Pad
  constructor: (@canvas, @id, @nickname) ->
    # canvas = $("canvas")
    @ctx = canvas[0].getContext("2d")

    @drawing = false
    @from = undefined
    @skipCount = 0
    @color = undefined
    @canvasOffset = canvas.offset()

    @setup()

  setup = ->
    @LineStream.emit "pad", @id

    @pad = @canvas.attr(
      width: 560
      height: 580
    ).hammer()

    pad.on "dragstart", @onDragStart
    pad.on "dragend", @onDragEnd
    pad.on "drag", @onDrag

    @setNickname(@nickname)

    @ctx.strokeStyle = @color
    @ctx.fillStyle = "#000000"
    @ctx.lineCap = "round"
    @ctx.lineWidth = 3
    @ctx.fillRect 0, 0, @canvas.width(), @canvas.height()

  #send padid to the sever
  onDrag = (event) ->
    if @drawing
      to = @getPosition(event)
      @drawLine @from, to, @color
      @LineStream.emit @id + ":drag", @nickname, to
      @from = to
      @skipCount = 0

  onDragStart = (event) ->
    @drawing = true
    @from = @getPosition(event)
    @LineStream.emit @id + ":dragstart", @nickname, @from, @color

  onDragEnd = ->
    @drawing = false
    @LineStream.emit @id + ":dragend", @nickname

  getPosition = (event) ->      
    # Hard coded to offset for sidebar
    x: parseInt(event.gesture.center.pageX - @canvasOffset.left)
    y: parseInt(event.gesture.center.pageY - @canvasOffset.top)

  drawLine: (from, to, color) ->
    @ctx.strokeStyle = color
    @ctx.beginPath()
    @ctx.moveTo from.x, from.y
    @ctx.lineTo to.x, to.y
    @ctx.closePath()
    @ctx.stroke()

  wipe: (emitAlso) ->
    @ctx.fillRect 0, 0, @canvas.width(), @canvas.height()
    @LineStream.emit @id + ":wipe", @nickname if emitAlso

  # Stop iOS from doing the bounce thing with the screen
  document.ontouchmove = (event) ->
    event.preventDefault()  

  #expose API
  close: ->
    @pad.off "dragstart", @onDragStart
    @pad.off "dragend", @onDragEnd
    @pad.off "drag", @onDrag

  getRandomColor = ->
    letters = "0123456789ABCDEF".split("")
    color = "#"
    i = 0

    while i < 6
      color += letters[Math.round(Math.random() * 15)]
      i++
    color

  setNickname = (nickname) ->
    localStorage.setItem "nickname", nickname
    color = localStorage.getItem("color-" + nickname)

    unless color
      @color = @getRandomColor()
      localStorage.setItem "color-" + nickname, color