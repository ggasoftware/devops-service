define([

  'jquery',
  'hbs!templates/modals/new_user',

  'backbone',
  'marionette',

  'App'

], function ($, modalTemplate, Backbone, Marionette, App) {

  'use strict';

  return Backbone.Marionette.CompositeView.extend({

    template: modalTemplate,
    tagName: 'div',
    className: 'modal fade in',

    events: {
      'click #reserve-server': 'reserveServer'
    },

    initialize: function () {
      console.log('init new user view')
      this.render();
      this.$el.modal('toggle');
    }

  });
});
