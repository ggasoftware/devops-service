define([

  'backbone',
  'marionette',

  'App',

  'hbs!templates/admin_dashboard/script/card'

], function(Backbone, Marionette, App, cardTemplate) {

  'use strict';
  return Backbone.Marionette.ItemView.extend({

    tagName: 'div',
    template: cardTemplate,

    behaviors: {
      HasBackLink: {
        resourceName: 'scripts'
      }
    },

    events: {
      'click .delete-button' : 'deleteScript'
    },

    deleteScript: function() {
      App.vent.trigger('script:delete', {script: this.model});
    }
  });

});
