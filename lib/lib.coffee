if Meteor.isClient
  focusText = (i) ->
    i.focus()
    i.select()

  # Trim left and right
  unless String::trim then String::trim = -> @replace /^\s+|\s+$/g, ""

  areElementsNonEmpty = (list) ->
    list.every (input) -> input.length