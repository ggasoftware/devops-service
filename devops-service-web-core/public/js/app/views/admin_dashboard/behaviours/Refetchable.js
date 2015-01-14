define([

  'backbone',
  'marionette',

  'App'

], function(Backbone, Marionette) {
  
  'use strict';

  return Marionette.Behavior.extend({

    events: {
      'click .fetchCollection' : 'reloadCollection'
    },

    reloadCollection: function() {
      this.view.trigger('reloadCollection');
    }

  });
});