Users = new Meteor.Collection("users")

Users.allow
  insert: (name, email) ->
    false # no cowboy inserts -- use createParty method