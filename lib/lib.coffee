@allCategory = [
  'math',
  'science',
  'english',
  'social_science',
  'computer',
  'business',
  'foreign_language',
]

Meteor.methods
  testFn: (url, context) ->
    console.log url
    console.log context