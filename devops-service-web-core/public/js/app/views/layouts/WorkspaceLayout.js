define([

  'App',
  'hbs!templates/layouts/projects'

], function (DSW, layoutTemplate) {

  'use strict';

  return Backbone.Marionette.LayoutView.extend({

    template: layoutTemplate,

    regions: {
      header: '#header',
      projects: '#projects',
      project_card: '#project-card',
      projectNav: '#project-nav'
    },

    events: {
      'click #project-create': 'createProject'
    },

    menu_item: '.user-dashboard',

    createProject: function () {
      DSW.vent.trigger('project:create');
    },

    serializeData: function () {
      return {
        accessLevels: DSW.request('get:accessLevels')
      }
    },

    initialize: function () {
      this.initEvents();
    },

    initEvents: function () {
      this.listenTo(DSW, 'workspace:show', this.showProjects);
      this.listenTo(DSW, 'workspace:nav:show', this.showNav);
      this.listenTo(DSW, 'workspace:nav:close', this.closeNav);
      this.listenTo(DSW.vent, 'layout:workspace:project:show', this.showProject);
      this.listenTo(DSW.vent, 'layout:workspace:reports:show', this.showReports);
      this.listenTo(DSW.vent, 'layout:workspace:manageEnvironments:show', this.showManageEnvironments);
      this.listenTo(DSW, 'layout:workspace:show:totalProjectsCount', this.showTotalProjectsCount);
    },

    showTotalProjectsCount: function (count) {
      this.$el.find('#projects-count-value').text(count);
    },

    showManageEnvironments: function (view) {
      this.project_card.show(view);
    },

    showReports: function () {
      DSW.Routers.user.navigate("#user/reports");
      var reportsView = new ReportsView({
        collection: DSW.reportRecords
      });
      this.project_card.show(reportsView);
    },

    showProjects: function (projectListView) {
      console.log('triggered woskpace:show');
      this.project_card.show(projectListView);
    },

    showNav: function (view) {
      this.projectNav.show(view);
    },

    closeNav: function () {
      this.projectNav.empty();
    },

    showProject: function (data) {
      var that = this;
      var findProjectAndShow = function (projectId) {
        var project = _.find(DSW.Collections.Projects._default.models, function (o) {
          return o.get('id') === projectId;
        });
        //var projectCardLayoutModule = DSW.module('Views.Layouts.ProjectCard');
        //var projectLayout = new projectCardLayoutModule.c({
        //  model: project
        //});
        that.project_card.show(projectLayout);
      };
      if (DSW.Collections.Projects._default.models.length === 0) {
        this.listenToOnce(DSW.Collections.Projects._default, 'sync', function () {
          findProjectAndShow(data);
        });
        return;
      }
      findProjectAndShow(data);
    },

    onShow: function () {
      //var projectsModule = app.module('Collections.Projects');
      //var projects = new projectsModule.c();
      //this.listenTo(projects, 'sync', function () {
      //  var projectListView = new ProjectsList({
      //    collection: projects
      //  });
      //  app.vent.trigger('layout:workspace', 'projects:show');
      //});
      //projects.fetch();
      ////App.request('fetch', App.Collections.Projects._);
      //this.delegateEvents();
    }

  });

});
