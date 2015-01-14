define([

  'jquery',
  'hbs!templates/modals/alert/delete_script',

  'backbone',
  'marionette',

  'App',

  'util/quickJobHandler'

], function($, modalTemplate, Backbone, Marionette, App, quickJobHandler) {

  'use strict';
  
  return Backbone.Marionette.CompositeView.extend({

    template: modalTemplate,
    tagName: 'div',
    className: 'modal fade in',

    events: {
      'click #execute' : 'deleteScript'
    },

    initialize: function(data) {
      this.model = data.model;
      this.$el.modal('toggle');
      this.render();

      var that = this;
      this.model.on('destroy', function() {
        that.$el.modal('hide');
      });
    },

    deleteScript: function() {
      $('#execute').button('loading');
      var deferred = quickJobHandler.deleteScript(this.model);

      deferred.done(function() {
        App.vent.trigger('script:delete:success');
      });
    }

  });
});
