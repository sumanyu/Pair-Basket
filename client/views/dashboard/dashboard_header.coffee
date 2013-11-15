Template.dashboardHeader.events =
  'click .ask-question' : (e, selector) ->
    e.preventDefault()

    if Meteor.user().karma > 1
      Session.set('askingQuestion?', true)
    else
      Session.set('showNotEnoughKarma?', true)

Template.dashboardHeader.helpers
  userKarma: ->
    if Meteor.user()
      Meteor.user().karma
    else
      karma = 0