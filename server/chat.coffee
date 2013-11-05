LineStream = new Meteor.Stream("lines")

LineStream.permissions.write ->
  true
LineStream.permissions.read ->
  true

chatStream = new Meteor.Stream("chat")

chatStream.permissions.write ->
  true

chatStream.permissions.read ->
  true