define([

  'jquery',

  'hbs!templates/admin_dashboard/image/card',

  'backbone',
  'marionette'

], function($, cardTemplate, Backbone) {

  'use strict';
  return Backbone.Marionette.ItemView.extend({

    tagName: 'div',
    template: cardTemplate,

    behaviors: {
      HasBackLink: {
        resourceName: 'images'
      }
    },

    events: {
      'click .delete-button' : 'deleteImage'
    },

    deleteImage: function() {
      // I didn't change this method because I didn't know how to create test Image.
      if(confirm('Sure?')) {
        var that = this;
        this.model.destroy({
          success: function(model, response) {
            var str = response.replace(/\n/g, '<br>');
            that.$el.empty();
            that.$el.html(str).wrap('<pre></pre>');
          },
          error: function(model, xhr) {
            var str = xhr.responseText.replace(/\n/g, '<br>');
            that.$el.empty();
            that.$el.html(str).wrap('<pre></pre>');
          }
        });
      } else {
          alert('Deletion aborted');
        }
    }

  });

});