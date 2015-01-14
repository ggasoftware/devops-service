define([

  'jquery',
  'hbs!templates/modals/alert/delete_server',

  'backbone',
  'marionette',

  'App'

], function($, deleteServer, Backbone, Marionette, App) {

  'use strict';

  return Backbone.Marionette.CompositeView.extend({

    template: deleteServer,
    tagName: 'div',
    className: 'modal fade in',

    events: {
      'click #execute' : 'deleteServer'
    },

    initialize: function() {
      this.$el.modal('toggle');
      this.render();

      var that = this;
      this.model.on('destroy', function() {
        that.$el.modal('hide');
      });

      this.on('promise:always', function() {
        that.$el.modal('hide');
      });

    },

    deleteServer: function() {
      $('#execute').button('loading');
      var val = $('#remove-by-instance-id').is(':checked');
      App.vent.trigger('server:delete', { model: this.model, client: this, removeByInstanceID: val });
    }

  });
});
