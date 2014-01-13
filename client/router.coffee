# Note using session variables inside any router makes the fn reactive

Router.configure
  notFoundTemplate: 'notFound'
  loadingTemplate: 'loading'
  yieldTemplates:
    header:
      to: 'header'
    footer:
      to: 'footer'      
  before: ->
    console.log "Router:Global:before: route name: #{@route.name}"

    # if not logged in, send to home page
    if !Meteor.loggingIn() and !Meteor.user()
      if @route.name != 'home'
        @redirect 'home'
    else if Meteor.user()
      console.log "Calling before, user exists"

      if not Session.get("haveAllCollectionsLoaded?")
        console.log "All collections have not loaded, stopping rendering"
        # Show loading screen until collections are loaded and then redirect to appropriate location
        @stop()
      else
        # Given all collections have loaded, proceed to path user requested
        console.log "All collections have loaded"

Router.map ->
  @route 'home',
    path: '/'
    layoutTemplate: 'landingLayout'
    template: 'landingPage'
    yieldTemplates:
      header:
        to: 'header'
      footer:
        to: 'footer'
    before: ->
      console.log "Calling before in home"

      # if logged in, send to dashboard
      if Meteor.user()
        @redirect 'dashboard'
        @stop()
    action: ->
      @render()

  @route 'dashboard',
    path: '/dashboard'
    layoutTemplate: 'dashboardLayout'
    template: 'questionsPage'
    yieldTemplates:
      header:
        to: 'header'
      footer:
        to: 'footer'
      feedback:
        to: 'feedback'
    data: () ->
      # allow html template to use userId of browsed profile
      return {
        headerAskQuestionButton: true
      }

    before: ->
      console.log "Calling before in dashboard"

      # Redirect to classroom session if user is subscribed to an existing session
      if Session.get('classroomSessionId')
        console.log "Pending session exists. Redirecting to classroom session"
        @redirect "/session/#{Session.get('classroomSessionId')}"
        @stop()

    action: ->
      console.log "Rendering dashboard"
      @render()

  @route 'session',
    path: '/session/:classroomSessionId?'
    layoutTemplate: 'classroomSessionLayout'
    template: 'classroomSessionPage'

    # Load is called before 'before'
    load: ->
      console.log "Calling Router:Session:Load"

    unload: ->
      console.log "Calling Router:Session:Unload"

    before: ->
      console.log "Calling before session"
      if not @params.classroomSessionId?
        console.log "You don't have a session"
        @redirect "dashboard"
        @stop()

      console.log "Router: classroomSessionId: #{@params.classroomSessionId}"
      console.log Session.get('classroomSessionId')

      # Add better routing security here
      # Someone could modify this equivalence and get access to the classroomSession
      if not Session.equals("classroomSessionId", @params.classroomSessionId)
        console.log "Router: Tutoring Session not found"
        @redirect "/dashboard"
        @stop()

    action: ->
      console.log "Rendering classroom session action"
      @render 'classroomSessionSidebar', 
        to: 'classroomSessionSidebar'

      @render()

  @route 'profile',
    path: '/profile'
    layoutTemplate: 'profileLayout'
    template: 'profilePage'
    yieldTemplates:
      header:
        to: 'header'
      footer:
        to: 'footer'
      feedback:
        to: 'feedback'

  @route 'profile-id',
    path: '/profile/:profileId'
    layoutTemplate: 'profileLayout'
    template: 'profilePage'
    yieldTemplates:
      header:
        to: 'header'
      footer:
        to: 'footer'
      feedback:
        to: 'feedback'
    data: () ->
      # allow html template to use userId of browsed profile
      return {
        profileId: @params.profileId
      }

    before: ->
      console.log "Calling before profileId"

      console.log "Router: profileId: #{@params.profileId}"
