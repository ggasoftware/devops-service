define([

  'hbs!templates/item/total-projects-count'

], function (Template) {

  'use strict';

  return Backbone.Marionette.ItemView.extend({

    serializeData: function () {
      return {
        totalProjectsCount: this.collection.length
      }
    },

    template: Template

  });
});
