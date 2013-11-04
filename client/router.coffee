Router.configure
  layoutTemplate: 'layout'
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
    template: 'questions_page'

  @route 'addQuestion',
    path: '/question/new'
    template: 'insertQuestionForm'
    
    # yieldTemplates:
    #   header:
    #     to: 'header'
    #   footer:
    #     to: 'footer'

  # @route 'dashboard',
  #   path: '/dashboard'