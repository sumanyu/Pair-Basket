Router.configure
  notFoundTemplate: 'notFound'
  loadingTemplate: 'loading'
  yieldTemplates:
    header:
      to: 'header'
    footer:
      to: 'footer'      
  before: ->
    # if not logged in, send to home page
    if !Meteor.user()
      # allow home
      if @route.name == 'home'
        return
      else
        @redirect 'home'
        @render (if Meteor.loggingIn() then @loading else 'landingPage')
        @stop()

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
      # if logged in, send to dashboard
      if Meteor.user()
        Router.go(Router.path('dashboard'))
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

  @route 'session',
    path: '/session/:sessionId?'
    layoutTemplate: 'tutoringSessionLayout'
    template: 'tutoringSessionPage'
    action: ->
      if not @params.sessionId?
        console.log "You don't have a session"
        @redirect "/dashboard"
      else
        console.log "Router: sessionId: #{@params.sessionId}"

        # Problem is when you refresh the page, client hasn't subscribed to TutoringSession
        # We could use localStorage to make sure user was subscribed and allow user to enter session
        # Or we could wait until user has subscribed and then either enter or exist the session 
        if TutoringSession.findOne({sessionId: @params.sessionId})
          
          Session.set("sessionId", @params.sessionId)

          @render 'tutoringSessionSidebar', 
            to: 'tutoringSessionSidebar'

          @render()
        else
          console.log "Router: Tutoring Session not found"
          @redirect "/dashboard"