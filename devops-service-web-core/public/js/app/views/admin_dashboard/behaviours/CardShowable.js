define([

  'backbone',
  'marionette',

  'App'

], function(Backbone, Marionette, App) {

  'use strict';
  return Marionette.Behavior.extend({

    events: {
     'click a': 'showResource'
    },

    showResource: function(e) {
      e.preventDefault();
      App.vent.trigger('admin:' + this.options.resourceName + ':show', this.view.model);
    }
  });
});
