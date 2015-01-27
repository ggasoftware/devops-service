require.config({

  baseUrl: './js/app',

  paths: {

    'jquery': '../libs/jquery/jquery',
    'jqueryui': '../libs/jqueryui/jquery-ui',
    'jquerymobile': '../libs/jquery-mobile/jquery.mobile',

    'underscore': '../libs/underscore/underscore',

    'backbone': '../libs/backbone/backbone',
    'backbone.syphon': '../libs/backbone.syphon/lib/backbone.syphon',
    'backbone.wreqr': '../libs/backbone.wreqr/backbone.wreqr',
    'backbone.babysitter': '../libs/backbone.babysitter/backbone.babysitter',

    'marionette': '../libs/backbone.marionette/backbone.marionette',
    'handlebars': '../libs/handlebars/handlebars',
    'hbs': '../libs/require-handlebars-plugin/hbs',
    'i18nprecompile': '../libs/require-handlebars-plugin/hbs/i18nprecompile',
    'json2': '../libs/require-handlebars-plugin/hbs/json2',
    'backbone.validateAll': '../libs/Backbone.validateAll/src/javascripts/Backbone.validateAll',
    'bootstrap': '../../env/lib/bootstrap',
    'text': '../libs/text/text',
    'backbone.caching-fetcher': '../libs/backbone.caching-fetcher/backbone.caching-fetcher',
    'envMainModule': '../../env/js/app/modules/Env',
    'envInitModule': '../../env/modules/Init',
  },

  shim: {
    'bootstrap': {
      'deps': ['jqueryui', 'jquery']
    },
    'jqueryui': ['jquery'],
    'jquerymobile': ['jqueryui'],

    'backbone': {
      'deps': ['underscore', 'jquery'],
      'exports': 'Backbone'
    },
    
    'backbone.syphon': {
      'deps': ['backbone'],
      'exports': 'Backbone.Syphon'
    },

    'marionette': {
      'deps': ['underscore', 'backbone', 'jquery'],
      'exports': 'Marionette'
    },

    'handlebars': {
      'exports': 'Handlebars'
    },

    'backbone.validateAll': ['backbone'],
    'backbone.caching-fetcher': ['backbone'],


    'jasmine': {
      'exports': 'jasmine'
    },

    'jasmine-html': {
      'deps': ['jasmine'],
      'exports': 'jasmine'
    },

    'boot': {
      deps: ['jasmine', 'jasmine-html'],
      exports: 'jasmine'
    }
  },

  hbs: {
    templateExtension: 'html',
    helperDirectory: 'templates/helpers/',
    i18nDirectory: 'templates/i18n/',
    disableI18n : true,

    compileOptions: {}
  }
});
