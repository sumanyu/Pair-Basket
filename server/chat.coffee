chatStream = new Meteor.Stream("chat")

chatStream.permissions.write ->
  true

chatStream.permissions.read ->
  true