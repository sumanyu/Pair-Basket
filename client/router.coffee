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

  @route 'test',
    path: '/test'
    template: 'test' 

  @route 'addQuestion',
    path: '/question/new'
    template: 'addQuestionForm'