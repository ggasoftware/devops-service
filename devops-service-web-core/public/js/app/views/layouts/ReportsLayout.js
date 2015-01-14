define([

  'hbs!templates/layouts/reports',

  'App'

], function (layoutTemplate, DSW) {

  'use strict';

  return Backbone.Marionette.LayoutView.extend({

    template: layoutTemplate,

    className: 'container-fluid dsw-rounded-panel',

    regions: {
      reportsWorkspace: '#reports-workspace',
      reportsNav: '#reports-nav'
    },

    initialize: function (opts) {
      this.header = opts.header;
    },

    templateHelpers: function() {
      var self = this;
      return {
        header: self.header
      }
    },

    onBeforeDestroy: function() {
      DSW.trigger('workspace:nav:close');
    }

  });

});
