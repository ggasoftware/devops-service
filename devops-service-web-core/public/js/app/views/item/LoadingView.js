define([

  'hbs!templates/loading', 'marionette'

], function (loadingTemplate, Marionette) {

  'use strict';
  
  return Backbone.Marionette.ItemView.extend({

    title: "Loading Data",
    message: "Please wait, data is loading",

    serializeData: function () {
      return {
        title: Marionette.getOption(this, "title"),
        message: Marionette.getOption(this, "message")
      }
    },

    template: loadingTemplate

  });
});
