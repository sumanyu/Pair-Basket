Template.hello.greeting = ->
  "Welcome to edu-hack."

Template.hello.events =
  'click input' : () ->
    console.log "You pressed the button"