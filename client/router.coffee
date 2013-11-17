Router.configure
  notFoundTemplate: 'notFound'
  loadingTemplate: 'loading'
  yieldTemplates:
    header:
      to: 'header'
    footer:
      to: 'footer'

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

  @route 'session',
    path: '/session/:sessionId?'
    layoutTemplate: 'tutoringSessionLayout'

    action: ->
      if not @params.sessionId?
        @redirect "/dashboard"
      else
        if TutoringSession.findOne({sessionId: @params.sessionId})
          Session.set('sessionId', @params.sessionId)
          
          @render 'tutoringSessionSidebar', 
            to: 'tutoringSessionSidebar'

          @render 'tutoringSessionPage'