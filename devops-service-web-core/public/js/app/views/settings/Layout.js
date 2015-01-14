define([

  'jquery',

  'backbone',
  'marionette',

  'hbs!templates/layouts/settings'

], function($, Backbone, Marionette, layoutTemplate) {

  'use strict';

  return Backbone.Marionette.LayoutView.extend({
    template : layoutTemplate,

    regions : {
      sidebar : '#sidebar',
      body : '#body'
    },

    menu_item : '.settings-page'

  });
});