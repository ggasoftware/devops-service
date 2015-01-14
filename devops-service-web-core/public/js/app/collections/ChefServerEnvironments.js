define([

'backbone', 'models/ChefServerEnvironment', 'App'

], function(Backbone, ChefServerEnvironment, App) {

 'use strict';

  App.module('Collections.ChefServerEnvironments', function(Envs) {

    Envs.c = Backbone.Collection.extend({

      model : ChefServerEnvironment,

      url : App.request('url:get', '/chef/servers'),

      initialize: function() {
        App.dlog('init ChefServerEnvironments collection', this);
      }

    });

  });

  return App.Collections.ChefServerEnvironments;

});
