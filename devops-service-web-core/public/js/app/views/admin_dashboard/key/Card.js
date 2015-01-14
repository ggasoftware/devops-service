define([

  'hbs!templates/admin_dashboard/key/card',

  'backbone',
  'marionette',

  'App',
  'util/quickJobHandler',
  'util/Redirector'

], function(cardTemplate, Backbone, Marionette, App, quickJobHandler, Redirector ) {

  'use strict';
  return Backbone.Marionette.ItemView.extend({

    tagName: 'div',
    template: cardTemplate,

    behaviors: {
      HasBackLink: {
        resourceName: 'keys'
      }
    },

    events: {
      "click .delete-button" : "deleteKey"
    },

    initialize: function() {
      this.model.on('destroy', function() {
        App.request('refetch', App.keys);
        Redirector.redirect_to('admin/keys');
      });
    },

    deleteKey: function() {
      if(confirm("Sure?")) {
        quickJobHandler.deleteKey(this.model);
      }
    }
  });


});
