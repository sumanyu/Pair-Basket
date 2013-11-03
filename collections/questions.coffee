Questions = new Meteor.Collection("questions")

Questions.allow
  insert: (title, userId, category, tags, karma_offered) ->
  	return true