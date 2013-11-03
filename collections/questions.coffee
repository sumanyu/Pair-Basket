Questions = new Meteor.Collection("questions")

Questions.allow
  insert: (title, userId, category, tags, karma) ->
  	return true