define([

  'App',
  'backbone',
  'marionette',

  'views/settings/Layout'

], function(App, Backbone, Marionette, SettingsLayout) {
  
  'use strict';

  return Backbone.Marionette.Controller.extend({

    index : function() {
      App.workspaceRegion.show(new SettingsLayout());
    }

  });

});