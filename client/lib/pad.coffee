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

  COLORS = 
    erase: 'rgba(0,0,0,1)'
    black: "#000000"

  # 'draw', 'erase'
  mode = undefined

  constructor: (_canvas, _id, _nickname) ->
    canvas = _canvas
    id = _id || Random.id()
    nickname = _nickname || "Anonymous"

    canvasOffset = canvas.offset()
    ctx = canvas[0].getContext("2d")

    mode = 'draw'

    setup()

  setup = ->
    LineStream = @LineStream

    LineStream.emit "pad", id

    pad = canvas.attr(
      width: 555
      height: 580
    ).hammer()

    setNickname(nickname)

    ctx.strokeStyle = color
    ctx.lineCap = "round"
    ctx.lineWidth = 3    

    pad.on "dragstart", dragStart
    pad.on "dragend", dragEnd
    pad.on "drag", drag

    # Set canvas state from localstorage
    loadCanvasState()

  dragStart = (event) ->
    drawing = true
    from = getPosition(event)
    LineStream.emit id + ":dragstart", nickname, from, color, mode    

  dragEnd = (event) ->
    drawing = false
    LineStream.emit id + ":dragend", nickname    

  drag = (event) ->
    if drawing
      to = getPosition(event)
      drawLine from, to
      LineStream.emit id + ":drag", nickname, to
      from = to
      skipCount = 0

  getPosition = (event) ->
    x: parseInt(event.gesture.center.pageX - canvasOffset.left)
    y: parseInt(event.gesture.center.pageY - canvasOffset.top)

  # Used for both remote and local draw actions
  drawLine = (from, to) ->
    drawLineOnCanvas (from, to)

    # Save this line to canvas state
    saveLineToCanvasState(from, to, ctx)

  # Simply draw a line on canvas
  drawLineOnCanvas = (from, to) ->
    ctx.beginPath()
    ctx.moveTo from.x, from.y
    ctx.lineTo to.x, to.y
    ctx.closePath()
    ctx.stroke()    

  # Canvas state schema
  # canvasState = 
  #   lines = [
  #     {
  #       from:
  #         x: 50
  #         y: 50
  #       to:
  #         x: 60
  #         y: 60
  #       strokeStyle: ctx.strokeStyle
  #       lineCap: ctx.lineCap
  #       lineWidth: ctx.lineWidth
  #       globalCompositeOperation: ctx.globalCompositeOperation
  #     },
  #     {
  #      ...
  #     }
  #   ]

  # Save line to canvas state
  saveLineToCanvasState = (from, to, ctx) ->
    # Prepare line object
    line = 
      from: from
      to: to
      strokeStyle: ctx.strokeStyle
      lineCap: ctx.lineCap
      lineWidth: ctx.lineWidth
      globalCompositeOperation: ctx.globalCompositeOperation

    # Prepare to store it on local storage
    canvasState = getCanvasState()

    if canvasState
      # Append to existing set of lines
      canvasState.lines.push line
      setCanvasState(canvasState)
    else
      console.log "Can't save line to canvas state. It doesn't even exist!"

  # Load lines to canvas
  loadLinesToCanvasState = (lines) ->
    lines.forEach (line) ->
      # Set context attributes to ctx
      ['strokeStyle', 'lineCap', 'lineWidth', 'globalCompositeOperation'].forEach (ctxStyle) ->
        ctx.ctxStyle = line.ctxStyle

      drawLine(line.from, line.to)

  # Loads canvas state from given state
  loadCanvasState = ->
    # Load from localstorage
    canvasState = getCanvasState()

    if canvasState
      # Load lines to canvas state
      loadLinesToCanvasState canvasState.lines
    else
      # start new localstorage canvas state
      canvasState = 
        background: 'testing'
        lines: []

      setCanvasState(canvasState)

  setCanvasState = (canvasState) ->
    localStorage.setItem("#{id}:canvasState", JSON.stringify(canvasState))

  getCanvasState = ->
    localStorage.getItem("#{id}:canvasState")?.toJSON()

  # We mimic the remote pad's conditions based on remoteMode
  drawRemoteLine: (from, to, _color, remoteMode) ->
    if remoteMode is 'draw'
      prepareCanvasToDraw(_color)
    else if remoteMode is 'erase'
      prepareCanvasToErase()

    drawLine(from, to)

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
    ctx.globalCompositeOperation = 'destination-out'
    ctx.strokeStyle = COLORS.erase
    ctx.lineWidth = 15

  prepareCanvasToDraw = (_color) ->
    ctx.globalCompositeOperation = 'source-over'
    ctx.strokeStyle = _color || color
    ctx.lineWidth = 3

  # Reset local pad's mode to IC after remote is done drawing/erasing 
  initializeModeInitialConditions: ->
    console.log "initializeModeInitialConditions, mode: #{mode}"
    if mode is 'draw' then prepareCanvasToDraw() else prepareCanvasToErase()

  setDrawingMode = (_mode) ->
    mode = _mode

  getDrawingMode: ->
    mode

  # Stop iOS from doing the bounce thing with the screen
  document.ontouchmove = (event) ->
    event.preventDefault()  

  close: ->
    console.log "Closing pad, unloading dragstart, dragend, drag"

    pad.off "dragstart", dragStart
    pad.off "dragend", dragEnd
    pad.off "drag", drag

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