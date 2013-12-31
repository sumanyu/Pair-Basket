# profileId = 

Deps.autorun ->
  if Session.get('profileId')
    profileId = Session.get('profileId')

    Meteor.call 'getUserProfile', profileId, (error, result) ->
      console.log "getting user profile"
      console.log error
      console.log result

      Session.set('profile', result)

Template.profilePage.helpers
  setProfileId: (profileId) ->
    if profileId
      Session.set('profileId', profileId)
    else
      Session.set('profileId', Meteor.userId())

  getProfileId: ->
    Session.get('profileId')

  viewingSelfProfile: ->
    Meteor.userId() == Session.get('profileId')

  profile: ->
    Session.get('profile')

  skills: ->
    Skills.find({})

  isSkillActive: (skill) ->
    if Session.get('profileId')

      # check if viewing self profile or other's
      if Meteor.userId() == Session.get('profileId')
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

    activeSkills = {}

    if Meteor.user().profile.activeSkills
      activeSkills = Meteor.user().profile.activeSkills

    clickedSkillId = e.target.id
    state = e.target.className.split(" ")[1]

    console.log "clicked skill box"
    console.log clickedSkillId
    console.log state

    # toggle active/inactive
    activeSkills[clickedSkillId] = !(state == 'active')

    console.log activeSkills[clickedSkillId]

    # update activeSkills
    Meteor.users.update(
      {_id: Meteor.userId()},
      {$set: {"profile.activeSkills": activeSkills}})

  'click .edit-skills-button': (e, selector) ->
    # toggle
    Session.set('editingSkills?', !Session.get('editingSkills?'))