define([

  'App',
  'jquery',
  'backbone',
  'marionette',
  'underscore',
  'handlebars',

  'hbs!templates/dashboard'

  ], function(App, $, Backbone, Marionette, _, Handlebars, layoutTemplate) {

  'use strict';

  return Backbone.Marionette.LayoutView.extend({
    template : layoutTemplate,

    regions : {
      tabs : '#tabs',
      table : '#table'
    },

    menu_item : '.admin-dashboard',

    events : {
      'click .sidebar a' : 'showResources'
    },

    setActivePage : function(page) {
      $('.sidebar li').removeClass('active');
      $('.sidebar li a[data-resource=' + page + ']').parent().addClass('active');
    },

    showResources : function(e) {
      e.preventDefault();
      var resourceName = $(e.target).data('resource');
      App.vent.trigger('admin:' + resourceName + ':index');
    }

  });
});