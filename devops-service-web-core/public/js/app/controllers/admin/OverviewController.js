define([

    'App',
    'backbone',
    'marionette',

    'views/admin_dashboard/Layout',
    'views/admin_dashboard/overview/Overview'

], function(App, Backbone, Marionette, AdminLayout, IndexView) {

  'use strict';

  return Backbone.Marionette.Controller.extend({

    prepareLayoutAndShowResources : function() {
      var layout = new AdminLayout();
      App.workspaceRegion.show(layout);
      this.showResources();
    },

    showResources : function() {
      App.workspaceRegion.currentView.setActivePage('overview');
      App.workspaceRegion.currentView.table.show(new IndexView());
    }

  });

});