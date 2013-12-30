Template.header.events =
  'click .ask-question' : (e, selector) ->
    e.preventDefault()

    if Meteor.user().karma > 1
      Session.set('askingQuestion?', true)
    else
      Session.set('showNotEnoughKarma?', true)

Template.header.helpers
  userKarma: ->
    if Meteor.user()
      Meteor.user().karma
    else
      karma = ''

Template.header.rendered = ->
  if not Meteor.user()
    $('.dropdown-toggle').html('Sign In')