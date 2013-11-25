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
    if !Meteor.user()
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
      dashboardHeader:
        to: 'dashboardHeader'
      landingFooter:
        to: 'landingFooter'
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
      dashboardHeader:
        to: 'dashboardHeader'
      dashboardFooter:
        to: 'dashboardFooter'
      feedback:
        to: 'feedback'
    before: ->
      console.log "Calling before in dashboard"
    action: ->
      console.log "Rendering dashboard"
      @render()

  @route 'session',
    path: '/session/:sessionId?'
    layoutTemplate: 'classroomSessionLayout'
    template: 'classroomSessionPage'
    before: ->
      console.log "Calling before session"
      if not @params.sessionId?
        console.log "You don't have a session"
        @redirect "/dashboard"    
        @stop()
    action: ->
        console.log "Router: sessionId: #{@params.sessionId}"

        if ClassroomSession.findOne({sessionId: @params.sessionId})
          Session.set("sessionId", @params.sessionId)

          @render 'classroomSessionSidebar', 
            to: 'classroomSessionSidebar'

          @render()
        else
          console.log "Router: Tutoring Session not found"
          @redirect "/dashboard"
