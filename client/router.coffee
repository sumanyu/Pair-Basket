Router.configure
  notFoundTemplate: 'notFound'
  loadingTemplate: 'loading'
  yieldTemplates:
    header:
      to: 'header'
    footer:
      to: 'footer'
  before: ->
    # no need to check at these URLs
    if @route.name == 'home'
      return

    # if not logged in, send to home page
    if !Meteor.user()
      Router.go(Router.path('home'))
      @render (if Meteor.loggingIn() then @loading else 'landingPage')
      @stop()

Router.map ->
  @route 'home',
    path: '/'
    layoutTemplate: 'landingLayout'
    template: 'landingPage'
    yieldTemplates:
      landingHeader:
        to: 'landingHeader'
      landingFooter:
        to: 'landingFooter'
    
  @route 'dashboard',
    path: '/dashboard'
    layoutTemplate: 'dashboardLayout'
    template: 'questionsPage'
    yieldTemplates:
      dashboardHeader:
        to: 'dashboardHeader'
      dashboardFooter:
        to: 'dashboardFooter'    

  # @route 'test',
  #   path: '/test'
  #   template: 'test' 

  # @route 'addQuestion',
  #   path: '/question/new'
  #   layoutTemplate: 'dashboardLayout'
  #   template: 'addQuestionForm'

  @route 'session',
    path: '/session/:sessionId?'
    layoutTemplate: 'tutoringSessionLayout'

    action: ->
      if not @params.sessionId?
        sessionId = Random.id()
        @redirect "/session/#{sessionId}"
      else
        Session.set('sessionId', @params.sessionId)
        
        @render 'tutoringSessionSidebar', 
          to: 'tutoringSessionSidebar'

        @render 'tutoringSessionPage'


    # after: ->
    #   console.log "Rendered?"
    #   Session.set("whiteboardLoaded?", true)