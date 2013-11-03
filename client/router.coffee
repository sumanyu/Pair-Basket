Router.configure
  layout: 'layout'
  notFoundTemplate: 'notFound'
  loadingTemplate: 'loading'

Router.map ->
  @route 'home',
    path: '/'
    template: 'questions_page'
    
    # yieldTemplates:
    #   header:
    #     to: 'header'
    #   footer:
    #     to: 'footer'

  # @route 'dashboard',
  #   path: '/dashboard'