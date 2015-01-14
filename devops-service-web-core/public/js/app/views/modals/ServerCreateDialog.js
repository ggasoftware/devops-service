define([

  'jquery',
  'hbs!templates/modals/server_create/dialog',

  'backbone'

], function($, modalTemplate, Backbone) {

  'use strict';

  return Backbone.Marionette.CompositeView.extend({

    template : modalTemplate,
    tagName : 'div',
    className : 'modal fade in',

    events : {
      'click #report-link' : 'clickedLink'
    },

    clickedLink : function() {
      this.$el.modal('hide');
    },

    templateHelpers : function() {
      var that = this;
      return {
        url : function() {
          return that.options.url;
        }
      };
    },

    initialize : function(data) {
      this.render();
      this.$el.modal('toggle');
      this.options.url = data.url;
    }

  });
});