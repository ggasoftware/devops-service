define([

  'App',
  'hbs!templates/navbar/navbar'

], function (DSW, navbarTemplate) {

  'use strict';

  DSW.module('Views.Layouts.Navbar', {
      
   moduleClass: DSW.moduleClasses.Common,

   define: function (module, app) {

    module.startWithParent = false;

    module.on('start', function () {

      module.log('started');

      var envModule = app.module('Env');
      envModule.prepareNavbarData();
      envModule.showCustomNavbar();

    });

    module.on('before:stop', function () {
      module.log('stopping...');
      app.navbarRegionNav.empty();
    });

    module.c = Backbone.Marionette.LayoutView.extend({

      template: navbarTemplate,

      templateHelpers: function () {
        var accessLevels = app.request('get:accessLevels');
        var level2 = accessLevels.level2();
        var level3 = accessLevels.level3();
        var pCount = this.projectsCount;
        return {
          username: function () {
            return window.username;
          },

          projectsCount: pCount,

          accessLevels: {
            level2: level2,
            level3: level3
          }
        }
      },

      events: {
        'click .nav li': 'changePage'
      },

      initialize: function (opts) {
        this.projectsCount = opts.projectsCount;
        app.vent.on('routeChanged', function () {
          $('.navbar li').removeClass('active');

          var currentItemClass = app.workspaceRegion.currentView.menu_item;
          $(currentItemClass).addClass('active');
        });

        this.listenTo(app, 'requestsCount:refresh', this.refreshRequestsCount);

        //TODO refactor

        this.listenTo(app, 'navbar:requests:setActive', function() { 
          this.$el.find('.nav.navbar-nav').children().removeClass('active');
          this.$el.find('li#requests').addClass('active');
        });

        this.listenTo(app, 'navbar:reports:setActive', function() { 
          this.$el.find('.nav.navbar-nav').children().removeClass('active');
          this.$el.find('li#reports').addClass('active');
        });

        this.listenTo(app, 'navbar:projects:setActive', function() { 
          this.$el.find('.nav.navbar-nav').children().removeClass('active');
          this.$el.find('li#projects').addClass('active');
        });

      },

      refreshRequestsCount: function() {
        var self = this;
        var promise = $.ajax({
          url: '/requests/count'
        }); 

        promise.done(function(r) {
          var count = JSON.parse(r).project;
          self.projectsCount = count;
          self.render();
        });
      },

      changePage: function (e) {
        $('.navbar li').removeClass('active');
        $(e.currentTarget).addClass('active');
      },

      setLoading: function () {
        this.ui.loading.removeClass('loaded');
      },

      setLoaded: function () {
        that.ui.loading.addClass('loaded');
      }

    });

  }});

  return DSW.Views.Layouts.Navbar;

});
