Template.profilePage.helpers
  getProfile: (profileId) ->
    if not profileId
      profileId = Meteor.userId()

    Meteor.call 'getUserProfile', profileId, (error, result) ->
      console.log "getting user profile"
      console.log error
      console.log result

      Session.set('profile', result)

  viewingSelfProfile: ->
    if Session.get('profile')
      Meteor.userId() == Session.get('profile').id

  profile: ->
    Session.get('profile')

  skills: ->
    Skills.find({})

  isSkillActive: (skill) ->
    if Session.get('profile')

      # check if viewing self profile or other's
      if Meteor.userId() == Session.get('profile').id
        activeSkills = Meteor.user().profile.activeSkills
      else
        if Session.get('profile')
          if Session.get('profile').activeSkills
            activeSkills = Session.get('profile').activeSkills

      # if activeSkills and skill exist, check the status
      if activeSkills
          if skill._id of activeSkills
            return activeSkills[skill._id]

    # if skill not recorded, it is false
    else
      return false

  editingSkills: () ->
    Session.get('editingSkills?')


Template.profilePage.events =
  'click .skill-box': (e, selector) ->
    # not editing: prevent skill toggle
    if not Session.get('editingSkills?')
      return

    clickedSkillId = e.target.id

    activeSkills = {}

    if Meteor.user().profile.activeSkills
      activeSkills = Meteor.user().profile.activeSkills

    # toggle active/inactive
    activeSkills[clickedSkillId] = !activeSkills[clickedSkillId]

    # update activeSkills
    Meteor.users.update(
      {_id: Meteor.userId()},
      {$set: {"profile.activeSkills": activeSkills}})

  'click .edit-skills-button': (e, selector) ->
    # toggle
    Session.set('editingSkills?', !Session.get('editingSkills?'))