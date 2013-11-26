class @Pad
  drawing = false
  from = undefined
  skipCount = 0
  color = undefined
  canvas = undefined
  canvasOffset = undefined
  ctx = undefined
  pad = undefined
  id = undefined
  nickname = undefined
  LineStream = undefined
  baseGlobalCompositeOperation = undefined

  COLORS = 
    erase: 'rgba(0,0,0,1)'
    black: "#000000"

  # 'draw', 'erase'
  mode = undefined

  # Used to co-ordinate remote and local pad's mode
  originalMode = undefined

  constructor: (_canvas, _id, _nickname) ->
    canvas = _canvas
    id = _id || Random.id()
    nickname = _nickname || "Anonymous"

    canvasOffset = canvas.offset()
    ctx = canvas[0].getContext("2d")

    # Used for erasing components
    baseGlobalCompositeOperation = ctx.globalCompositeOperation
    mode = 'draw'

    setup(@)

  # Global window context for @
  setup = (context) ->
    LineStream = @LineStream

    LineStream.emit "pad", id

    pad = canvas.attr(
      width: 555
      height: 580
    ).hammer()

    pad.on "dragstart", (event) =>
      drawing = true
      from = getPosition(event)
      LineStream.emit id + ":dragstart", nickname, from, color, mode

    pad.on "dragend", (event) => 
      drawing = false
      LineStream.emit id + ":dragend", nickname

    pad.on "drag", (event) =>
      if drawing
        to = getPosition(event)
        context.drawLine from, to
        LineStream.emit id + ":drag", nickname, to
        from = to
        skipCount = 0

    setNickname(nickname)

    ctx.strokeStyle = color
    ctx.lineCap = "round"
    ctx.lineWidth = 3

  getPosition = (event) ->
    x: parseInt(event.gesture.center.pageX - canvasOffset.left)
    y: parseInt(event.gesture.center.pageY - canvasOffset.top)

  drawLine: (from, to) ->
    ctx.beginPath()
    ctx.moveTo from.x, from.y
    ctx.lineTo to.x, to.y
    ctx.closePath()
    ctx.stroke()

  drawRemoteLine: (from, to, _color, remoteMode) ->
    if remoteMode is 'draw'
      prepareCanvasToDraw(_color)
    else if remoteMode is 'erase'
      prepareCanvasToErase()

    @drawLine(from, to)

  wipe: (emitAlso) ->
    ctx.clearRect 0, 0, canvas.width(), canvas.height()
    LineStream.emit id + ":wipe", nickname if emitAlso

  toggleModes: ->
    if @getDrawingMode() is 'erase'
      @startDrawMode()
    else
      @startEraseMode()

  startEraseMode: ->
    setDrawingMode 'erase'
    prepareCanvasToErase()

  startDrawMode: ->
    setDrawingMode 'draw'
    prepareCanvasToDraw()

  prepareCanvasToErase = ->
    baseGlobalCompositeOperation = ctx.globalCompositeOperation
    ctx.globalCompositeOperation = 'destination-out'
    ctx.strokeStyle = COLORS.erase
    ctx.lineWidth = 15

  prepareCanvasToDraw = (_color) ->
    ctx.globalCompositeOperation = baseGlobalCompositeOperation
    ctx.strokeStyle = _color || color
    ctx.lineWidth = 3

  # Reset local pad's mode after remote is done drawing/erasing 
  initializeModeInitialConditions: ->
    if mode is 'draw' then prepareCanvasToDraw() else prepareCanvasToErase()

  setDrawingMode = (_mode) ->
    mode = _mode

  getDrawingMode: ->
    mode

  # Stop iOS from doing the bounce thing with the screen
  document.ontouchmove = (event) ->
    event.preventDefault()  

  # Not using it apparently
  close: ->
    console.log "closing pad"
    console.log @

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
      color = getRandomColor()
      localStorage.setItem "color-" + nickname, color