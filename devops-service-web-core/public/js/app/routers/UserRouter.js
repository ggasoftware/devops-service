define([

  'App',
  'backbone',
  'marionette'

], function(DSW, Backbone) {

  'use strict';

  return Backbone.Marionette.AppRouter.extend({
    initialize: function () {
      console.log('init router');
    },

    appRoutes : {
      '' : 'projects',
      'projects': 'projects',
      'projects/new': 'newProject',
      'projects/request': 'requestNewProject',
      'projects/:id': 'projectCard',
      'projects/:id/environments': 'projectEnvironments',
      'reports' : 'reports',
      'reports/:type' : 'reports',
      'reports/:type/:date' : 'reports',
      'requests' : 'requests'
    }

  });
});
