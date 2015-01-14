define([

  'App',
  'views/footer/Footer',
  'views/layouts/NavbarLayout',
  'modules/Workspace',
  'jquery'

], function (App, Footer, Navbar, Workspace, $) {

  'use strict';

  return Backbone.Marionette.Controller.extend({

    initialize: function () {
      Footer.start();
      Navbar.start();
      Workspace.start();

      App.vent.on('layout:workspace', function (action, options) {
        App.vent.trigger('layout:workspace' + ':' + action, options);
      });

      this.listenTo(App, 'controller:reports:show', this.reports);
      this.listenTo(App, 'controller:requests:show', this.requests);

    },

    projects: function () {
      App.trigger('workspace:nav:close');
      require(['modules/ProjectsList'], function (ProjectsList) {
        ProjectsList.start();
        ProjectsList.showProjectsList();
      });
    },

    projectCard: function (projectName) {
      require(['modules/ProjectCard'], function (ProjectCard) {
        ProjectCard.start();
        ProjectCard.showProjectCard(projectName);
      });
    }
    ,

    newProject: function () {
      require(['modules/CreateProject'], function (CreateProject) {
        CreateProject.start();
        CreateProject.showModal();
      });
    },

    requestNewProject: function() {
      require(['modules/CreateProject'], function(CreateProject) {
        CreateProject.start(); 
        CreateProject.showModal({request: true}); 
      });
    },

    projectEnvironments: function (projectName) {
      require(['modules/ManageEnvironments'], function (ManageEnvironments) {
        ManageEnvironments.start();
        ManageEnvironments.showDialog(projectName);
      })
    },

    requests: function() {
      require(['modules/Requests'], function(Requests) {
        Requests.start(); 
        Requests.showProjectRequests();
      });
    },

    reports: function (type, date) {
      type = type || 'all';
      date = date || App.request('get:todayDate');

      require(['modules/Reports'], function (Reports) {
        Reports.start();
        Reports.showReports({date: date, type: type});
      });
    }

  });

});
