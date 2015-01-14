define([

  'backbone',

  'App'

], function(Backbone, App) {

  'use strict';

  App.module('Collections.SidebarElements', function(SidebarElements) {

    SidebarElements.c = Backbone.Collection.extend({

      initialize : function() {
        App.dlog("init SidebarElements", this);
      }

    });

    App.addInitializer(function() {
      App.Collections.SidebarElements._default = new SidebarElements.c();
    });

  });



});
