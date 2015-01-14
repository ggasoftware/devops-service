define([

  'App',
  'jquery',
  'backbone',
  'marionette',
  'underscore',
  'handlebars',
  'hbs!templates/layouts/projects'

], function (App, $, Backbone, Marionette, _, Handlebars, layoutTemplate) {

  'use strict';

  return Backbone.Marionette.LayoutView.extend({
    template: layoutTemplate,

    regions: {
      navbar: '#navbar',
      workspace: '#workspace',
      footer: '#footer'
    },

    events: {

    },

    initialize: function () {
      console.log('init applayout', this);
    }

  });
});
