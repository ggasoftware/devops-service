define([

  'jquery',
  'backbone',

  'marionette',
  'handlebars'

], function ($, Backbone) {

  'use strict';

  var App = new Backbone.Marionette.Application({

    moduleClasses: {
      Common: Marionette.Module.extend({
        log: function(message, obj) {
     	  message = message || "";  
	  obj = obj || "";  
	  console.info("[" + this.moduleName + "]: " + message, obj);  
        } 
      }),
    },

    log: function (type, message) {
      if (type === 'err') {
        this.execute('console:error', message);
      }
    },

    dlog: function (params, o) {
        console.info(params, o);
    }
  });

  App.reqres.setHandler('get:todayDate', function() {
    var date = new Date();
    var dd = ('0' + date.getDate()).slice(-2);
    var mm = ('0' + (date.getMonth() + 1)).slice(-2);
    var yyyy = date.getFullYear();
    var dateString = yyyy + "-" + mm + "-" + dd;
    console.log('getted date ', dateString);
    return dateString;
  });

  App.reqres.setHandler('get:dateIncrement', function(date) {
    var current = date.getDate();
    date.setDate(current + 1);
    console.log('get:dateIncrement', current, date);
    return date;
  });

  App.reqres.setHandler('set:serviceHostname', function (hostname) {
    App.reqres.setHandler('get:serviceHostname', function () {
      return hostname;
    })
  });

  App.reqres.setHandler('set:currentUser', function (username) {
    App.reqres.setHandler('get:currentUser', function () {
      return username;
    })
  });

  App.addRegions({
    workspaceRegion: '#workspace',
    alertRegion: '#alert',
    consoleRegion: '#console',
    footerRegion: '#footer',
    navbarRegion: '#navbar',
    projectNavbarRegion: '#project-nav',
    navbarRegionNav: '#navbar-nav',
    breadcrumbsRegion: '#breadcrumbs',
    sidebarInfoRegion: '#sidebar-info'
  });

  App.addInitializer(function () {
    Backbone.history.start();
  });

  App.module('Views', function (Views, app) {

    App.module('Views.Composite', function (Composite) {

      Composite.addInitializer(function () {
        //require(['views/composite/ProjectNavigation']);
      });

    });

    App.module('Views.Modals', function (Modals) {

      Modals.addInitializer(function () {
        require(['views/modals/ManageUsers']);
      });

      app.module('Views.Modals.Alerts', function (Alerts) {

        Alerts.addInitializer(function () {
          require(['views/modals/alert/DeleteProject']);
        });

      });

    });

  });

  return App;

});
