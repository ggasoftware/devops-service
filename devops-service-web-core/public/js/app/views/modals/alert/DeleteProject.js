define([

  'hbs!templates/modals/alert/delete_project',

  'App'

], function (modalTemplate, DSW) {

  'use strict';

  return Backbone.Marionette.CompositeView.extend({

    template: modalTemplate,
    tagName: 'div',
    className: 'modal fade in',

    events: {
      'click #execute': 'deleteProject'
    },

    initialize: function (data) {
      this.model = data.model;
      this.$el.modal('toggle');
      this.render();

      var self = this;

      this.on('promise:always', function () {
        self.$el.modal('hide');
      });

    },

    deleteProject: function () {
      $('#execute').button('loading');
      DSW.vent.trigger('project:delete', {model: this.model, client: this});
    }

  });

});
