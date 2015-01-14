define([

  'backbone',
  'marionette',

  'App'

], function(Backbone, Marionette, App) {

  'use strict';

  return Marionette.Behavior.extend({

    events : {
      'click .js-back' : 'showResources'
    },

    showResources : function(e) {
      e.preventDefault();
      App.vent.trigger('admin:' + this.options.resourceName + ':index');
    }
  });
});