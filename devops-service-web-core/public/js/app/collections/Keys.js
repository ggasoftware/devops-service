define([

  'backbone',

  'models/Key',

  'App'

],  function(Backbone, Key, App) {

  'use strict';

  App.module('Collections.Keys', function(Keys) {

    Keys.c = Backbone.Collection.extend({
      model : Key,
      url : App.request('url:get', '/collections/keys'),

      initialize: function() {
        App.dlog('init Keys collection', this);
      }

    });

    App.addInitializer(function() {
      App.Collections.Keys._default = new Keys.c();
    });

  });


});
