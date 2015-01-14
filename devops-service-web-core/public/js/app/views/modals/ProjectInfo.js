define([

  'jquery',
  'hbs!templates/modals/project-info',

  'backbone'

], function($, modalTemplate, Backbone) {

  'use strict';

  return Backbone.Marionette.CompositeView.extend({

    template : modalTemplate,
    tagName : 'div',
    className : 'modal fade in',

    events : {},

    templateHelpers : function() {
      var that = this;
      var rawResponseJSON = JSON.stringify(that.model.get('rawResponse'), null, '\t');
      var rawResponseServersJSON = JSON.stringify(that.model.get('servers').rawResponse, null, '\t');
      return {
        rawResponseJSON : rawResponseJSON,
        rawResponseServersJSON : rawResponseServersJSON
      };
    },

    initialize : function(data) {
      this.model = data.model;
      this.render();
      this.$el.modal('toggle');
    }

  });
});
