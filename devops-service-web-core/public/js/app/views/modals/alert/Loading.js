define([

  'jquery',

  'backbone',
  'marionette',

  'App',
  'hbs!templates/modals/add_users/loading'

], function($, Backbone, Marionette, App, loadingModalTemplate) {

  'use strict';

  return Backbone.Marionette.CompositeView.extend({

    template : loadingModalTemplate,
    tagName : 'div',
    className : 'modal fade in without-backdrop',

    initialize : function() {
      this.render();
      this.$el.modal('toggle');

      this.on('deps:fetched', function() {
        this.$el.modal('hide');
      });
    }

  });

});
