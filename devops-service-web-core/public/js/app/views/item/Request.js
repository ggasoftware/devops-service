define([

  'hbs!templates/item/request',

  'App'

], function (Template, DSW) {

  'use strict';

  return Backbone.Marionette.ItemView.extend({

    template: Template,

    events: {
      "click #apply-request" : "applyRequest"
    },

    applyRequest: function() {
      var self = this;
      var id = self.model.get('id');
      var promise = $.ajax({
        url: '/request/' + id + '/apply',
        method: 'post'
      });  

      var button = this.$el.find('#apply-request');

      button.button('loading');

      promise.always(function () {
        button.button('reset');
      });

      promise.done(function(r) {
        var message = JSON.parse(r).message;
        DSW.trigger('alert:show', {message: message});
        DSW.trigger('controller:requests:show');
        DSW.trigger('requestsCount:refresh');
      });
    },

    templateHelpers: function() {
      var self = this; 
      return {
        json: function() {
          var obj = self.model.get('object');
          var json = JSON.stringify(obj, null, 4);
          console.log(json);
          return json;
        }
      }
    }

  });
});
