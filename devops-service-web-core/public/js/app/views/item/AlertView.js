define([

  'hbs!templates/alert'

], function (alertTemplate) {

  'use strict';

  return Backbone.Marionette.ItemView.extend({

    title: "alert",
    message: "alert text",
    type: "success",

    serializeData: function () {
      return {
        title: Marionette.getOption(this, "title"),
        message: Marionette.getOption(this, "message"),
        type: Marionette.getOption(this, "type")
      }
    },

    onRender: function () {
      var el = this.$el.find('.alert-message');
      el.fadeIn();
    },

    onDomRefresh: function () {
      var el = this.$el.find('.alert-message');
      window.setTimeout(function () {
        el.fadeOut('slow');
      }, 5000);
    },

    template: alertTemplate

  });

});
